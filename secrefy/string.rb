class String
  require 'digest'

  def hasht
    num_string = (self+(2**Message::BLOCK_BITS).to_s).each_byte.map(&:to_s).join.to_i(23).to_s
    sub_string_length = (num_string.length/3.0).ceil
    s, o, a = num_string.scan(/.{1,#{sub_string_length}}/).map(&:to_i)
    9.times do |n|
      s, o, a = hashter(s, o, a, n)
    end
    num = (s.to_s + o.to_s + a.to_s).to_i
    num = num.to_s(2)[0...Message::BLOCK_BITS]
    "%0.#{Message::BLOCK_BITS}d" % num
    # Digest::SHA512.new.hexdigest(self).to_i(16).to_s(2)
    # Digest::MD5.new.hexdigest(self).to_i(16).to_s(2)
  end

  def hashter(s, o, a, n)
    s = s.mix(n, true)

    s ^= a

    o = o.mix(n+1, false)

    o ^= s

    a = a.mix(n+2, true)

    a ^= o

    s %= 2**(Message::BLOCK_BITS)
    o %= 2**(Message::BLOCK_BITS)
    a %= 2**(Message::BLOCK_BITS)
    [o, a, s]
  end

  def diff(other, base)
    num1 = self.gsub(/\s+/, "").to_i(base)
    num2 = other.gsub(/\s+/, "").to_i(base)
    bin1 = num1.to_s(2).rjust(Message::BLOCK_BITS, '0')
    bin2 = num2.to_s(2).rjust(Message::BLOCK_BITS, '0')
    count = bin1.chars.zip(bin2.chars).inject(0){|c, (s1,s2)| s1!=s2 ? c + 1 : c}
    percent = count/bin1.length.to_f * 100
  end

  def std_dev
    top = 2*ones*zeros*(2*ones*zeros-ones-zeros)
    bottom = ((ones+zeros)**2)*(ones+zeros-1)
    (top.to_f / bottom.to_f)**(0.5)
  end

  def r_barred
    (2*ones*zeros).to_f / (ones+zeros).to_f + 1
  end

  def z
    ((runs - r_barred).to_f / std_dev.to_f).abs
  end

  def runs
    runs = 1
    (1..self.length-1).each do |n|
      runs += 1 if self[n-1] != self[n]
    end
    runs
  end

  def zeros
    count('0')
  end

  def ones
    count('1')
  end
end
