# Make a Markov Chain
#
# chain = MarkovChain.new
# chain.add_text("I know that you are special.")
# puts chain[0]
# => {:""=>{:I=>1, :know=>1, :that=>1, :you=>1, :are=>1, :"special."=>1}}
#
class MarkovChain
  attr_reader :max_links

  # This is the default hash to hold a Markov Chain
  #
  # It's built so you can do CHAIN_HASH[:key1][:key2] += 1
  #
  CHAIN_HASH = Hash.new { |hash, key| hash[key] = Hash.new(0) }.freeze

  def initialize(ml)
    @max_links = ml
    @markov_chains = []
    (0..ml).each { |i| self[i] = CHAIN_HASH.dup }
  end

  def [](index)
    fail RangeError, out_of_range_message(index) if index > max_links
    @markov_chains[index]
  end

  def []=(index, value)
    fail RangeError, out_of_range_message(index) if index > max_links
    @markov_chains[index] = value
  end

  def max_links=(ml)
    @max_links = ml
    (@markov_chains.length..ml).each { |i| self[i] = CHAIN_HASH.dup }
    ml
  end

  def add_text(text)
    text = text.tr("\r\n\t", ' ')
    words = text.split(' ')
    (0..max_links).each { |n| add_to_markov_chains(n, words) }
  end

  def add_text_from_filename(filename)
    message = "Adding #{filename}"
    puts message
    length = message.length
    text = File.read(filename)
    words = text.split(' ')
    wordcount = words.count
    word_operations = (0..max_links).count * wordcount
    step = word_operations / length
    counter = 0
    words.each do |w|
      counter += 1
      print '.' if counter % step == 0
      self[0][:''][w.to_sym] += 1
    end
    (1..max_links).each do |n|
      limit = words.length - 1
      (n - 1...limit).each do |i|
        counter += 1
        print '.' if counter % step == 0
        self[n][prev_words(n, words, i)][next_word(words, i)] += 1
      end
    end
    puts
  end

  def chain_from_words(words)
    fail "#{words} must be symbol" unless words.is_a?(Symbol)
    self[words.to_s.split(' ').length][words.downcase]
  end

  def inspect
    count = -1
    string = "MarkovChain: { @max_links: #{max_links}, lengths:"
    array = @markov_chains.map do |mc|
      count += 1
      " #{count}: [#{mc.count}:#{mc.keys.inject(0) { |a, k| a + mc[k].count }}]"
    end
    string + array.join + ' }'
  end

  private

  def add_to_markov_chains(n, words)
    n == 0 ? markov_chain_0(words) : normal_markov_chain(n, words)
  end

  def markov_chain_0(words)
    words.each { |w| self[0][:''][w.to_sym] += 1 }
  end

  def normal_markov_chain(n, words)
    limit = words.length - 1
    (n - 1...limit).each do |i|
      self[n][prev_words(n, words, i)][next_word(words, i)] += 1
    end
  end

  def prev_words(n, words, i)
    words[i - n + 1..i].join(' ').downcase.to_sym
  end

  def next_word(words, i)
    words[i + 1].to_sym
  end

  def out_of_range_message(index)
    "Index [#{index}] is outside range (0..#{max_links})"
  end
end
