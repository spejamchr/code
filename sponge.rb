require "Prime"
# A hashing algorithm
#
class Sponge < Array

  COLUMNS = 25

  def initialize(power = 0)
    @power = power
    @word_bits = 2**power
    @max_word_value = 2**word_bits - 1
    super(COLUMNS, 0)
  end

  def hash(string)
    number = string_to_int(string)
    padded = pad(number)
    absorb(padded)
    flatten.map { |s| format("%0#{word_bits / 4}x", s) }.first
  end

  #private

  attr_reader :power, :word_bits, :max_word_value

  def string_to_int(string)
    string.bytes.map { |b| format(b.to_s(2), "%0.#{word_bits}d") }.join.to_i(2)
  end

  # Pads a number to have a number of bits divisible by word_bits
  #
  # @return Integer
  #
  def pad(number)
    bits = number.to_s(2)
    extra_length = word_bits - bits.length % word_bits
    return number if extra_length == word_bits
    (bits + "0" * (extra_length - 1) + "1").to_i(2)
  end

  def absorb_piece(number)
    fail "Too many bits" if number > max_word_value
    self[0] ^= number
  end

  def prime(n)
    @primes = Prime.take(n + 1) unless defined?(@prime) && @prime[n]
    (@primes[n]**(1 / 3.0) * 10**16 + 1).to_i
  end

  def too_many_bits_message(int) # :nodoc:
    "Integer (#{int}) is too big (max is #{max_word_value})"
  end

  def rot_test(int) # :nodoc:
    fail too_many_bits_message(int) if int > max_word_value
    fail "Integer (#{int}) cannot be negative" if int < 0
  end

  # Implement bitwise right circular shift
  #
  # @param Integer [0..max_word_value], Integer
  # @return Integer [0..max_word_value]
  #
  def rrot(index, n = 1)
    int = self[index % COLUMNS]
    rot_test(int)
    n %= word_bits
    (int >> n) | (int << (word_bits - n)) & max_word_value
  end

  # Implement bitwise left circular shift
  #
  # @param Integer [0..max_word_value], Integer
  # @return Integer [0..max_word_value]
  #
  def lrot(index, n = 1)
    int = self[index % COLUMNS]
    rot_test(int)
    n %= word_bits
    (int << n | int >> (word_bits - n)) & max_word_value
  end

  def mod_add(index, n)
    (self[index % COLUMNS] + n) % (max_word_value + 1)
  end

  def col_mix(t)
    (0...COLUMNS).each do |i|
      a = i + 1
      b = i + 2
      c = i * (t + 1)
      self[i] ^= rrot(a, a) ^ lrot(b, b)
      self[i] = mod_add(i, prime(c) << c)
    end
  end

  def mod_xor(t)
    self[t % COLUMNS] = (self[t % COLUMNS] ^ prime(t)) % (max_word_value + 1)
  end

  def col_switch(t)
    a = rrot(0, 3 * word_bits / 7)
    b = lrot((t + 1) % COLUMNS, 2 * word_bits / 5)
    self[(t + 1) % COLUMNS] = a
    self[0] = b
  end

  def f
    (10).times do |t|
      col_mix(t)
      mod_xor(t)
      col_switch(t)
      rotate!
    end
  end

  def absorb(padded)
    until padded.zero?
      absorb_piece(padded % 2**word_bits)
      padded >>= word_bits
      f
    end
  end
end

# Parent class for other Hash classes
#
class Spash
  def self.power
    @power
  end

  def hash(string)
    Sponge.new(self.class.power).hash(string)
  end
end

# Get a 128-bit hash from a string
#
# Usage:
#
#   $ S128.new.hash("a string")
#   >> <a 128-bit hash, in a hex string>
#
class S128 < Spash; @power = 7; end

# Get a 256-bit hash from a string
#
# Usage:
#
#   $ S256.new.hash("a string")
#   >> <a 256-bit hash, in a hex string>
#
class S256 < Spash; @power = 8; end

# Get a 512-bit hash from a string
#
# Usage:
#
#   $ S512.new.hash("a string")
#   >> <a 512-bit hash, in a hex string>
#
class S512 < Spash; @power = 9; end

string = "Spencer James Christiansen may have come here before. But
maybe not. Who knows? He knows. That\"s who. How may I communicate myself to
thee, sweet Ophelia? Who is Ophelia, anyway? I\"ve heard the name, but I
cannot remember if she is from Greek legend, or if she is from Shakespeare.
Quite possibly she is in both. I dunno. Oh well. What should I write next?
'Orson Scott Card is a master storyteller ... Enchanted is the ultimate proof'
-- Anne McCaffrey"

puts Sponge.new.hash(string)
puts S128.new.hash(string)
puts S256.new.hash(string)
puts S512.new.hash(string)
