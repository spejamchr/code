EMOJI =
  ('😀'..'🙏').to_a.join +
  ('🌀'..'🌠').to_a.join +
  ('🌭'..'🎓').to_a.join +
  ('🎠'..'🏓').to_a.join +
  ('🏠'..'🏰').to_a.join +
  ('🏸'..'🔽').to_a.join +
  '🕋🕌🕍🕎'

# Shamir's Secret Sharing
module Secret
  class << self
    PUBLIC = 2**521 - 1

    # @param [Integer] secret
    # @param [Integer] share_count - the number of shares to create
    # @param [Integer] req - the number of shares required to recover the secret
    def share(secret, share_count, req)
      raise ArgumentError, 'Secret would be irrecoverable' if share_count < req
      raise ArgumentError, 'Secret is too large' if secret >= PUBLIC

      coefficients = [secret] + Array.new(req - 1) { rand_int }
      polynomial = make_polynomial(coefficients)
      xs = (1..share_count)
      ys = xs.map(&polynomial)
      xs.zip(ys)
    end

    def retrieve(tokens)
      (0...tokens.count).yield_self do |range|
        range.sum do |j|
          tokens[j][1] * range.inject(1) do |p, m|
            # Regular division usually works, but divmod always works.
            m == j ? p : p * divmod(tokens[m][0], tokens[m][0] - tokens[j][0])
          end
        end
      end % PUBLIC
    end

    JOINER = ' '.freeze

    def easy_share(secret, share_count, req, chars)
      chars = chars.delete(JOINER)
      share(IntStringEncode.string_to_int(secret), share_count, req).map do |h|
        h
          .map { |n| IntStringEncode.simple_int_to_string(n, chars) }
          .join(JOINER)
      end
    end

    def easy_retrieve(string_tokens, chars)
      chars = chars.delete(JOINER)
      int_tokens = string_tokens.map do |t|
        t
          .split(JOINER)
          .map { |n| IntStringEncode.simple_string_to_int(n, chars) }
      end
      IntStringEncode.int_to_string(retrieve(int_tokens))
    end

    private

    def rand_int
      rand(PUBLIC)
    end

    def make_polynomial(coeffs)
      lambda do |x|
        coeffs.reverse.inject(0) do |accum, coeff|
          accum *= x
          accum += coeff
          accum % PUBLIC
        end
      end
    end

    def extended_gcd(numer, denom)
      x = 0
      last_x = 1
      while denom != 0
        quot = numer / denom
        numer, denom = denom, numer % denom
        x, last_x = last_x - quot * x, x
      end
      last_x
    end

    def divmod(num, denom)
      extended_gcd(denom, PUBLIC) * num
    end
  end
end

# Methods for converting ints to strings & vice-versa
module IntStringEncode
  class << self
    # @param [String] str
    # @return [Integer]
    def string_to_int(str)
      str
        .force_encoding(Encoding::UTF_8)
        .each_byte
        .map { |b| b.to_s(16).rjust(2, '0') }
        .join
        .to_i(16)
    end

    # @param [Integer] int
    # @return [String]
    def int_to_string(int)
      int
        .to_s(16)
        .yield_self { |s| s.length.even? ? s : '0' + s }
        .scan(/../)
        .map { |b| b.to_i(16).chr }
        .join
        .force_encoding(Encoding::UTF_8)
    end

    # Convert a string restricted to the characters in `chars` to an integer
    # @param [String] simple
    # @param [String] chars
    # @return [Integer]
    def simple_string_to_int(simple, chars = ('!'..'~').to_a.join)
      arr = chars.split('').uniq
      simple.reverse.each_char.with_index.inject(0) do |n, (c, i)|
        n + arr.index(c) * arr.length**i
      end
    end

    # Convert an integer to a string using `chars` as the encoding
    # @param [Integer] int
    # @param [String] chars
    # @return [String]
    def simple_int_to_string(int, chars = ('!'..'~').to_a.join)
      arr = chars.split('').uniq
      str = ''
      until int.zero?
        str += arr[int % arr.length]
        int /= arr.length
      end
      str.reverse
    end
  end
end

a = 'cookieskunkpetuniabubble12'
puts "length: #{a.length}"
# i = IntStringEncode.string_to_int(a)
# puts
# s = Secret.share(i, 5, 3)
# puts s.map { |h| h.map { |n| IntStringEncode.simple_int_to_string(n, EMOJI) }.join(' ') }
# puts

# puts IntStringEncode.int_to_string(Secret.retrieve(s.sample(3)))
# puts
# tokens = []
# puts "Enter tokens"

# tokens << gets.chomp until tokens.last == ''
# puts
# tokens.pop
# tokens.map! { |t| t.split(' ').map { |c| IntStringEncode.simple_string_to_int(c, EMOJI) } }

# s = Secret.retrieve(tokens)
# puts IntStringEncode.int_to_string(s)

key = ('!'..'~').to_a.join + EMOJI
puts 'EASY'
puts
puts sec = Secret.easy_share(a, 5, 3, key)
puts
puts Secret.easy_retrieve(sec.sample(3), key)
# puts
# tokens = []
# puts 'Enter tokens'
# tokens << gets.chomp until tokens.last == ''
# tokens.pop
# puts Secret.easy_retrieve(tokens, key)
