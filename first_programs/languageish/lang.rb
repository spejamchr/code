unless @constants_loaded
  load 'constants.rb'
end

class Text
  attr_accessor :text
end

class Word < Text

  def initialize
    word = rand_english_letter
    lowest_length = rand_length
    while word[-1] != "\n" && word.length < lowest_length
      word.chomp!
      chain_letters = word.chars.last(rand(1..10)).join.to_sym
      word << rand_english_letter(chain_letters)
    end

    @text = word.chomp
  end

  private

  def rand_length
    lengths = ::WL.keys
    frequencies = lengths.map {|l| ::WL[l] }
    sum = frequencies.inject(:+)
    num = rand sum
    running_sum = frequencies.first
    index = 0
    while num > running_sum
      index += 1
      running_sum += frequencies[index]
    end
    lengths[index]
  end

  def rand_english_letter(letters = :"\n")
    letters = letters.to_sym
    chain = ::MarkovChains[letters.length]
    letter_chain = chain[letters]
    return "\n" if letter_chain.nil?

    sum = letter_chain.inject(0) {|sum,(key,frequency)| sum += frequency}

    num = rand sum
    letters = letter_chain.keys
    frequencies = letters.map {|l| letter_chain[l] }
    running_sum = frequencies.first
    index = 0
    while num > running_sum
      index += 1
      running_sum += frequencies[index]
    end
    letters[index].to_s
  end
end

class Sentence < Text

  def initialize
    sentence = [Word.new.text.capitalize]
    sentence << (1..rand(5..20)).map { Word.new.text }
    @text = sentence.join(' ') + '.'
  end
end

class Paragraph < Text

  def initialize
    @text = "\t" + (1..rand(3..10)).map { Sentence.new.text }.join(' ')
  end
end

class Essay < Text

  def initialize
    @text = (1..rand(3..7)).map { Paragraph.new.text }.join("\n")
  end
end
