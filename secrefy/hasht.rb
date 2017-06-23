class Hasht
  require 'Prime'

  PRIMES = Prime.take(100).map { |n| ((n**(1.0 / 3.0)) * 10**16).to_i }.freeze

  attr_reader :block_length, :hash, :string

  def initialize(string, block_length = 4096)
    @block_length = block_length

    num_string = (string + (2**block_length).to_s).each_byte.map(&:to_s).join.to_i(23).to_s
    sub_string_length = (num_string.length / 3.0).ceil
    s, o, a = num_string.scan(/.{1,#{sub_string_length}}/).map(&:to_i)
    9.times do |n|
      s, o, a = hashter(s, o, a, n)
    end
    num = (s.to_s + o.to_s + a.to_s).to_i
    num = num.to_s(2)[0...block_length]
    @hash = "%0.#{block_length}d" % num
    @string = base(@hash.to_i(2), 64)
  end

  private

  def base(m, n)
    # TODO: Use all of UTF-8 (besides control sequences)
    # codes = (32..126).to_a + (161..191).to_a
    # chrs = (0..n).to_a.map { |i| i.chr(Encoding::UTF_8) }
    chrs = ('0'..'9').to_a + ('A'..'Z').to_a + ('a'..'z').to_a + ['#', '&']
    result = ""
    while m >= n
      s = m % n
      result = chrs[s] + result
      m = m / n
    end
    chrs[m] + result
  end

  def hashter(s, o, a, n)
    s = mix(s, n, true)

    s ^= a

    o = mix(o, n + 1, false)

    o ^= s

    a = mix(a, n + 2, true)

    a ^= o

    s %= 2**(block_length)
    o %= 2**(block_length)
    a %= 2**(block_length)
    [o, a, s]
  end

  def mix(s, n, r)
    n = n * 3 + 1
    s *= numbers(n)
    s = rotate(s, numbers(n + 1)) if r
    s = lotate(s, numbers(n + 1)) unless r
    s * numbers(n + 2)
  end

  def rotate(s, n = 1)
    n %= block_length
    (s >> n) | (s << (block_length - n)) & (2**block_length - 1)
  end

  def lotate(s, n = 1)
    n %= block_length
    (s << n | s >> (block_length - n)) & (2**block_length - 1)
  end

  def numbers(n)
    PRIMES[n % PRIMES.length]
  end
end

puts Hasht.new('hi').string
