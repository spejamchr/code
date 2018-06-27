# frozen_string_literal: true

# Make a Markov Chain
#
# chain = MarkovChain.new(0)
# chain.add_text("I know that you are special.")
# puts chain[0]
# #=> {:""=>{:I=>1, :know=>1, :that=>1, :you=>1, :are=>1, :"special."=>1}}
#
class MarkovChain
  attr_reader :max_links

  # This is the default hash to hold a Markov Chain
  #
  # It's built so you can do CHAIN_HASH[key1] << key2
  #
  CHAIN_HASH = Hash.new { |hash, key| hash[key] = [] }.freeze

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
    words = text.split(/\s+/)
    (0..max_links).each { |n| add_to_markov_chains(n, words) }
  end

  def add_text_from_filename(filename)
    add_text(File.read(filename))
  end

  # Get array of all words following `words`, which is an array of strings.
  def chain_from_words(words)
    self[words.length][words]
  end

  def inspect
    count = -1
    string = "#<MarkovChain: { @max_links: #{max_links}, lengths:"
    array = @markov_chains.map.with_index do |mc, i|
      " #{i}: [#{mc.count}:#{mc.values.flatten.uniq.count}]"
    end
    string + array.join + ' }>'
  end

  private

  def add_to_markov_chains(n, words)
    return self[0][[]] += words if n.zero?

    words.each_cons(n + 1) do |group|
      self[n][group[0..-2]] << group[-1]
    end
  end

  def out_of_range_message(index)
    "Index [#{index}] is outside range (0..#{max_links})"
  end
end
