class Integer
  require 'Prime'

  PRIMES = Prime.take(168).map{|n| ((n**(1.0/3.0))*10**16/2*2+1).to_i }.freeze

  def numbers(n)
    PRIMES[n % PRIMES.length]
  end

  def rand_chrs
    o = (' '..'~').to_a
    (0...self).map { o[rand(o.length)] }.join
  end

  def rotate(n=1)
    n %= Message::BLOCK_BITS
    (self >> n) | (self << (Message::BLOCK_BITS - n)) & (2**Message::BLOCK_BITS - 1)
  end

  def lotate(n=1)
    n %= Message::BLOCK_BITS
    (self << n | self >> (Message::BLOCK_BITS - n)) & (2**Message::BLOCK_BITS - 1)
  end

  def mix(n, r)
    s = self
    n = n * 3 + 1
    s *= numbers(n)
    s = s.rotate(numbers(n+1)) if r
    s = s.lotate(numbers(n+1)) unless r
    s *= numbers(n+2)
  end

  # From https://en.wikipedia.org/wiki/Modular_exponentiation#Right-to-left%5Fbinary%5Fmethod
  def mod_power(exp, mod)
    base = self
    result = 1
    base = base % mod
    while exp > 0
      if (exp % 2 == 1)
        result = (result * base) % mod
      end
      exp = exp >> 1
      base = (base * base) % mod
    end
    result
  end
end
