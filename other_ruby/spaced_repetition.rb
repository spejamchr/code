# frozen_string_literal: true

# Store information about each specific item
#
class SRSItem
  attr_reader :value

  def initialize(value, last_iter)
    @value = value
    @last_iter = last_iter
    @familiarity = 1
  end

  def yes(iter)
    max = 2.0
    @familiarity += max - familiarity / (iter - last_iter + familiarity / max)
    @last_iter = iter
  end

  def no(iter)
    @familiarity = 0
    @last_iter = iter
  end

  def score(iter)
    return -Float::INFINITY if iter - 1 == last_iter

    burden * (iter - last_iter)
  end

  def burden
    2**(1 - familiarity)
  end

  private

  attr_reader :last_iter, :familiarity
end

# Use Spaced Repetition to study a list of things
#
class SRS
  MAX_BURDEN = 1.2

  def initialize(items)
    @unseen = items
    @seen = []
    @current_item = SRSItem.new(unseen.shift, 0)
    @iter = 0
  end

  def yes
    current_item.yes(iter)
    self.next.value
  end

  def no
    current_item.no(iter)
    self.next.value
  end

  def current
    current_item.value
  end

  protected

  def next
    @seen.push(current_item)
    @iter += 1
    @current_item = next_item
  end

  private

  attr_reader :unseen, :iter, :current_item, :seen

  def next_item
    if !unseen.empty? && seen.sum(&:burden) < MAX_BURDEN
      SRSItem.new(unseen.shift, iter)
    else
      seen.max_by { |i| i.score(iter) }
    end
  end
end

# seen = []
# r = SRS.new((0...60).to_a)
# 1200.times do |i|
#   n = r.current
#   success = seen.include?(n)
#   # success = rand < 1.9
#   seen << n unless success
#   puts i.to_s.rjust(5) + '| ' + n.to_s.rjust(n).ljust(200) + (success ? '' : '<-')
#   success ? r.yes : r.no
# end
# puts
# puts

# Use Spaced Repetition to study a list of things
#
# Actually, this will give you the sequence of indices of items to study, not
# the sequence of items themselves.
#
# Closely doubles the space between successful attempts, and avoids
# back-to-back viewings (unless there's only one item).
#
# Also, I think the resulting sequence is pretty.
#
# Works by assigning the first item (0) a series of group indices, so that the
# difference between consecutive indices doubles, starting at 0. Then, for each
# additional item (n), assign a similar series of group indices, so that the
# difference between consecutive indices doubles, starting at the first unused
# index among all indices used for the previous (0..n-1) items. Once the group
# indices are assigned, the items within the group are ordered so that the
# least well-acquainted items are first.
#
# That handles the case for when there is an unending list of items to learn,
# and the user correctly knows each item.
#
# For cases where there is a finite list of items to learn, and/or where the
# user does not know all the items correctly, there are some complications.
# Basically, the group indices of an item are "reset" any time the item is not
# correctly known, and when the list of items ends, gaps in groups are
# closed/skipped. There is also some logic to prevent showing the same item
# multiple times in a row.
#
# Usage:
class SRS2
  # @param [Integer] item_count
  #   The number of items to be studied
  #
  # @param [Numeric] item_chance
  #   The chance (from 0-1) that a user will randomly get the question correct
  #   Used to calculate the "known" value of the set.
  def initialize(item_count, item_chance)
    raise 'Expected an integer' unless item_count.is_a?(Integer)
    raise 'Expected a numeric' unless item_chance.is_a?(Numeric)

    @item_count = item_count
    @unseen = (0...item_count).to_a
    @item_chance = item_chance.clamp(0, 1).to_f
    @practicing = {}
    @group = 0
    @line = 0
    @prev = nil
    @current_keys = key_from_unseen
  end

  # Return an approximate measure of how well the user knows the set
  def known
    # puts practicing.map { |k, v| [k, v[:count]] }.inspect
    # puts practicing.map { |k, v| [k, 1 - item_chance**(v[:count] - 1)] }.inspect
    # puts "item_count: #{item_count}"
    sum = practicing.values.map { |v| 1 - item_chance**(v[:count] - 1) }.sum
    sum / item_count
  end

  # Iterate through the indices of the items to be learned
  #
  # @param optional [Integer] lines
  #   The number of items to study. If nil (default), the sequence won't stop.
  # @block [Array<Integer>]
  #   Each iteration yields an array of three integers: The index of the item
  #   to study, the number of iterations (0-based), and the current group index
  #   (0-based).
  #
  #   For each iteration of the block the caller should return either `true` or
  #   `false`, depending if the user successfully knew the item or not.
  def iter(lines = nil, &block)
    raise 'Block required' unless block_given?
    raise 'Expected an integer' unless lines.nil? || lines.is_a?(Integer)

    target_line = line + lines unless lines.nil?

    loop do
      find_keys

      iter_keys(target_line, &block)
      break if target_line == line

      @group += 1
    end
  end

  private

  attr_reader :item_count, :item_chance, :practicing, :unseen, :group, :line, :prev, :current_keys

  def correct(key)
    practicing[key][:group] += 2**practicing[key][:count]
    practicing[key][:count] += 2
  end

  def incorrect(key)
    practicing[key][:group] += 1
    practicing[key][:count] = 1
  end

  def capture_results(key)
    raise 'Block required' unless block_given?

    result = yield(key, line, group)
    raise 'Expected the block to yield a Boolean' unless result == !!result

    result ? correct(key) : incorrect(key)
    @prev = key
    @line += 1
  end

  def iter_keys(target_line, &block)
    raise 'Block required' unless block_given?

    delayed = nil
    current_keys.sort_by { |k| practicing[k][:count] }.each do |k|
      # Delay the current key if it was the previous key
      next delayed = k if k == prev

      # Test the current key
      capture_results(k, &block)
      break if target_line == line

      next unless delayed

      # Test any delayed key
      capture_results(delayed, &block)
      delayed = nil
      break if target_line == line
    end

    return if target_line == line || delayed.nil?

    # Test any delayed key
    if prev == delayed && practicing.count > 1
      # Unless that delayed key was also the previous key. Then bump it to the
      # next group.
      incorrect(delayed)
    else
      capture_results(delayed, &block)
    end
  end

  def keys_from_group
    practicing.filter { |_, v| v[:group] == group }.keys.sort
  end

  def key_from_unseen
    new = unseen.shift
    return [] if new.nil?

    practicing[new] = { group: group, count: 1 }
    [new]
  end

  def remove_group_gaps
    prev_group = group
    diff = 0
    practicing.sort_by { |_, v| v[:group] }.each do |k, v|
      this_diff = v[:group] - prev_group - 1
      prev_group = v[:group]
      this_diff = 0 if this_diff < 1

      diff += this_diff
      practicing[k][:group] -= diff
    end
  end

  def keys_from_shifted_group
    group_diff = practicing.values.map { |v| v[:group] }.min - group

    practicing.each do |_, v|
      v[:group] -= group_diff
      # v[:count] -= 1 if v[:count] > 1
    end

    remove_group_gaps

    keys_from_group
  end

  def find_keys
    # Try practicing what we've already seen
    @current_keys = keys_from_group

    # Or learn something new
    @current_keys = key_from_unseen if current_keys.empty?

    # Our backlog of new items is empty, so go back to previously seen items
    @current_keys = keys_from_shifted_group if current_keys.empty?
  end
end

seen = []
r = SRS2.new(1000, 0.5)
old_group = nil
r.iter(100) { |n, _, _| print "#{n}, "; true }

r.iter(100) do |n, i, g|
  # puts "known: #{r.known}"
  success = true || seen.include?(n)
  # success = rand < 0.95
  seen << n unless success
  puts " #{g}".rjust(225, '-') if g != old_group
  old_group = g
  puts i.to_s.rjust(5) + '| ' + n.to_s.rjust(n + 1).ljust(200) + (success ? '' : '<-')

  break success if r.known > 0.97
  success
end

# r = SRS2.new(50)
# old_group = nil
# r.iter do |n, i, g|
#   puts " #{g}".rjust(225, '-') if g != old_group
#   old_group = g
#   print i.to_s.rjust(5) + '| ' + n.to_s.rjust(n).ljust(200)
#   success = gets.chomp == 'y'

#   success
# end

# Use SRS to study a list of things
class Study
  # @param [Hash] items
  #   The keys are questions, the values are their answers
  #
  # @param [Numeric] item_chance
  #   See SRS2.new
  #
  def initialize(items, item_chance)
    @items = items.to_a
    @srs = SRS2.new(items.count, item_chance)
  end

  # Start an interactive study session
  #
  # Each session consists of a sequence of questions. For each question, type
  # your answer. To quit, use ctrl-c.
  def study
    @srs.iter do |n, i, g|
      question, answer = @items[n]
      puts "\n#{question} (#{@srs.known})"
      if gets.downcase.strip.to_sym == answer
        true
      else
        puts "#{answer} "
        false
      end
    end
  end
end

katakana_monograph = {
  ア: :a,
  イ: :i,
  ウ: :u,
  エ: :e,
  オ: :o,
  カ: :ka,
  キ: :ki,
  ク: :ku,
  ケ: :ke,
  コ: :ko,
  サ: :sa,
  シ: :shi,
  ス: :su,
  セ: :se,
  ソ: :so,
  タ: :ta,
  チ: :chi,
  ツ: :tsu,
  テ: :te,
  ト: :to,
  ナ: :na,
  ニ: :ni,
  ヌ: :nu,
  ネ: :ne,
  ノ: :no,
  ハ: :ha,
  ヒ: :hi,
  フ: :fu,
  ヘ: :he,
  ホ: :ho,
  マ: :ma,
  ミ: :mi,
  ム: :mu,
  メ: :me,
  モ: :mo,
  ラ: :ra,
  リ: :ri,
  ル: :ru,
  レ: :re,
  ロ: :ro,
  ワ: :wa,
  ヲ: :wo,
  ン: :n,
  ヤ: :ya,
  ユ: :yu,
  ヨ: :yo,
}

katakana_diacritic = {
  ガ: :ga,
  ギ: :gi,
  グ: :gu,
  ゲ: :ge,
  ゴ: :go,
  ザ: :za,
  ジ: :ji,
  ズ: :zu,
  ゼ: :ze,
  ゾ: :zo,
  ダ: :da,
  ヂ: :ji,
  ヅ: :zu,
  デ: :de,
  ド: :do,
  バ: :ba,
  ビ: :bi,
  ブ: :bu,
  ベ: :be,
  ボ: :bo,
  パ: :pa,
  ピ: :pi,
  プ: :pu,
  ペ: :pe,
  ポ: :po,
}

katakana_digraph = {
  キャ: :kya,
  キュ: :kyu,
  キョ: :kyo,
  シャ: :sha,
  シュ: :shu,
  ショ: :sho,
  チャ: :cha,
  チュ: :chu,
  チョ: :cho,
  ニャ: :nya,
  ニュ: :nyu,
  ニョ: :nyo,
  ヒャ: :hya,
  ヒュ: :hyu,
  ヒョ: :hyo,
  ミャ: :mya,
  ミュ: :myu,
  ミョ: :myo,
  リャ: :rya,
  リュ: :ryu,
  リョ: :ryo,
  ギャ: :gya,
  ギュ: :gyu,
  ギョ: :gyo,
  ジャ: :ja,
  ジュ: :ju,
  ジョ: :jo,
  ヂャ: :ja,
  ヂュ: :ju,
  ヂョ: :jo,
  ビャ: :bya,
  ビュ: :byu,
  ビョ: :byo,
  ピャ: :pya,
  ピュ: :pyu,
  ピョ: :pyo,
}

hiragana_monograph = {
  あ: :a,
  い: :i,
  う: :u,
  え: :e,
  お: :o,
  か: :ka,
  き: :ki,
  く: :ku,
  け: :ke,
  こ: :ko,
  さ: :sa,
  し: :shi,
  す: :su,
  せ: :se,
  そ: :so,
  た: :ta,
  ち: :chi,
  つ: :tsu,
  て: :te,
  と: :to,
  な: :na,
  に: :ni,
  ぬ: :nu,
  ね: :ne,
  の: :no,
  は: :ha,
  ひ: :hi,
  ふ: :fu,
  へ: :he,
  ほ: :ho,
  ま: :ma,
  み: :mi,
  む: :mu,
  め: :me,
  も: :mo,
  や: :ya,
  ゆ: :yu,
  よ: :yo,
  ら: :ra,
  り: :ri,
  る: :ru,
  れ: :re,
  ろ: :ro,
  わ: :wa,
  を: :wo,
  ん: :n,
}

hiragana_diacritic = {
  が: :ga,
  ぎ: :gi,
  ぐ: :gu,
  げ: :ge,
  ご: :go,
  ざ: :za,
  じ: :ji,
  ず: :zu,
  ぜ: :ze,
  ぞ: :zo,
  だ: :da,
  ぢ: :ji,
  づ: :zu,
  で: :de,
  ど: :do,
  ば: :ba,
  び: :bi,
  ぶ: :bu,
  べ: :be,
  ぼ: :bo,
  ぱ: :pa,
  ぴ: :pi,
  ぷ: :pu,
  ぺ: :pe,
  ぽ: :po,
}

hiragana_digraph = {
  きゃ: :kya,
  きゅ: :kyu,
  きょ: :kyo,
  しゃ: :sha,
  しゅ: :shu,
  しょ: :sho,
  ちゃ: :cha,
  ちゅ: :chu,
  ちょ: :cho,
  にゃ: :nya,
  にゅ: :nyu,
  にょ: :nyo,
  ひゃ: :hya,
  ひゅ: :hyu,
  ひょ: :hyo,
  みゃ: :mya,
  みゅ: :myu,
  みょ: :myo,
  りゃ: :rya,
  りゅ: :ryu,
  りょ: :ryo,
  ぎゃ: :gya,
  ぎゅ: :gyu,
  ぎょ: :gyo,
  じゃ: :ja,
  じゅ: :ju,
  じょ: :jo,
  ぢゃ: :ja,
  ぢゅ: :ju,
  ぢょ: :jo,
  びゃ: :bya,
  びゅ: :byu,
  びょ: :byo,
  ぴゃ: :pya,
  ぴゅ: :pyu,
  ぴょ: :pyo,
}

katakana = katakana_monograph.merge(katakana_digraph).merge(katakana_diacritic)
hiragana = hiragana_monograph.merge(hiragana_digraph).merge(hiragana_diacritic)

all = katakana.merge(hiragana)
all_monograph = katakana_monograph.merge(hiragana_monograph)

dummy_words = all_monograph.to_a.shuffle.each_slice(3).map { |s|
  s.transpose.map { |a| a.map(&:to_s).inject(:+).to_sym }
}.to_h

Study.new(dummy_words.to_a.shuffle.to_h, 0.125).study
