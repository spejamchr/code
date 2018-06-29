class RC4

  NONCE_LENGTH = 16
  NONCE_SIG = "ñ".freeze

  attr_reader :nonce

  # key: String
  # message: String
  def initialize(key, message)
    if message[0] == NONCE_SIG
      @nonce = message[1, NONCE_LENGTH].bytes
      @encrypting = false
      message = message[(1 + NONCE_LENGTH)..-1]
    else
      @nonce = NONCE_LENGTH.times.map { rand(256) }
      @encrypting = true
    end


    @message = message.bytes
    @s = (0..255).to_a
    @i = 0
    @j = 0
    init_s(key.bytes)

    # There is a weakness in RC4's key setup routine. Strengthen the routine by
    # discarding the first bytes of the keystream.
    1000.times { next_k }

    @array = encode
  end

  def to_a
    @array
  end

  def to_s
    s = @array.map(&:chr).join
    return s unless @encrypting
    NONCE_SIG +
      @nonce.map(&:chr).join.force_encoding("UTF-8") +
      s.force_encoding("UTF-8")
  end

  def to_hex
    @array.map { |n| hex(n) }.join
  end

  private

  def init_s(key)
    256.times.inject(0) do |j, i|
      j = (j + @s[i] + key[i % key.size] + @nonce[i % @nonce.size]) % 256
      @s[i], @s[j] = @s[j], @s[i]
      j
    end
  end

  def next_k
    @i = (@i + 1) % 256
    @j = (@j + @s[@i]) % 256

    @s[@i], @s[@j] = @s[@j], @s[@i]

    @s[(@s[@i] + @s[@j]) % 256]
  end

  # n: Int(0..255)
  def hex(n)
    n < 16 ? "0#{n.to_s(16)}" : n.to_s(16)
  end

  def encode
    ks = @message.length.times.map { next_k }
    @message.zip(ks).map { |m, k| m ^ k }
  end
end

print "Key please: "
key = gets.chomp

print "Message: "
o_mess = eval(gets.chomp)

rc4 = RC4.new(key, o_mess)
puts "nonce:"
puts rc4.nonce.inspect
puts "hex:"
puts rc4.to_hex
puts "string:"
puts rc4.to_s.inspect
puts rc4.to_s
