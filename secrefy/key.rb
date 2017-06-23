class Key
  attr_accessor :key

  ZIP = 3.freeze

  def initialize(key)
    @key = key.hasht
  end

  def unzip(message)
    bit_strings = message.byte_groups.reverse
    bits = []
    bit_strings.each_with_index do |bit_string, i|
      if i == bit_strings.count-1
        bits[i] = xor(bit_string, key)
      else
        k = xor(bit_strings[i+1].hasht, key)
        k = xor(k.reverse, key)
        bits[i] = xor(bit_string, k)
      end
    end
    bits
  end

  def secrefy(message)
    secret = message.dup
    unless secret.text.length > 64
      secret.text = secret.text + (65 - secret.text.length).rand_chrs
    end

    ZIP.times do
      secret.text = secret.text.reverse
      secret.zip(key)
    end
    secret
  end

  def unsecrefy(message)
    text = message.dup
    ZIP.times do
      text.unzip(key)
      text.text = text.text.reverse
    end
    text
  end
end
