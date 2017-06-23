require 'forwardable'
load 'markov_chain.rb'

# Create a babble generator
#
# Example:
#
# writer = Writer.new_from_text(some_text)
# puts writer.sentence  # => [String of Babble]
#
class Writer
  extend Forwardable

  SENTENCE_SPLITTER = /(?<!Mr|Mrs|Ms|Dr|Jr|Sr)[\.\?\!](?!\w|\d)/
  DEFAULT_MAX_LINKS = 2

  attr_reader :markov_chain
  def_delegators :markov_chain, :max_links
  def_delegators :markov_chain, :max_links=
  def_delegators :markov_chain, :add_text
  def_delegators :markov_chain, :add_text_from_filename
  def_delegators :markov_chain, :chain_from_words

  def self.new_from_text(text, ml = DEFAULT_MAX_LINKS)
    writer = new(ml)
    writer.add_text(text)
    writer
  end

  def initialize(ml = DEFAULT_MAX_LINKS)
    @markov_chain = MarkovChain.new(ml)
  end

  def sentence(before_word = :"")
    array = [first_word(before_word)]
    until sentence_is_finished?(array)
      chain_words = array.last(max_links).join(' ').to_sym
      array << random_word(chain_words)
    end

    array.join(' ').chomp
  end

  def paragraph(before_word = :"")
    (1..rand(3..10)).inject(sentence(before_word)) do |par, _|
      par + ' ' + sentence(par.split(' ').last(max_links).join(' ').to_sym)
    end
  end

  def essay(before_word = :"")
    (1..(rand(3..5))).inject(paragraph(before_word)) do |ess, _|
      ess + "\n" + paragraph(ess.split(' ').last(max_links).join(' ').to_sym)
    end
  end

  def inspect
    "Writer: @markov_chain: #{markov_chain.inspect}"
  end

  private

  def create_chain(words)
    chain = chain_from_words(words)
    chain = chain_from_words(words.to_s.split(' ').last.to_sym) if chain.empty?
    chain
  end

  def weighted_rand(weights)
    u = 0
    num = rand(weights.values.inject(:+))
    ranges = weights.map { |k, v| [u += v, k] }
    ranges.find { |(v, _)| v > num }.last
  end

  def random_word(words = :"")
    chain = create_chain(words)
    return :"\n" if chain.empty?
    weighted_rand(chain)
  end

  def first_word(before_word)
    word = random_word(before_word)
    ('a'..'z').include?(word[0]) ? word.capitalize : word
  end

  def sentence_is_finished?(array)
    array[-1] == :"\n" || array.join(' ').scan(SENTENCE_SPLITTER).count > 0
  end
end
