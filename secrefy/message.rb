class Message
  BLOCK_BITS = 512

  attr_accessor :text

  def initialize(text)
    @text = text
  end

  def byte_groups
    text.each_byte.map {|byte|
      sprintf "%08b", byte
    }.join.scan(/.{1,#{BLOCK_BITS}}/)
  end

  def zip(key)
    code_groups = []
    byte_groups.each_with_index do |group, i|
      k = key
      k = xor(byte_groups[i+1], k).hasht if i < byte_groups.count - 1
      k = xor(code_groups[i-1], k).hasht if i > 0
      k = xor(code_groups.first, k).hasht if i == byte_groups.count - 1
      k = xor(byte_groups.last, k).hasht if i == 0
      code_groups[i] = xor(group, k)
    end
    @text = code_groups.join.scan(/.{1,8}/).map{|n| n.to_i(2).chr}.join
  end

  def unzip(key)
    text_groups = []
    groups = byte_groups.reverse
    groups.each_with_index do |group, i|
      k = key
      k = xor(text_groups[i-1], key).hasht if i > 0
      k = xor(groups[i+1], k).hasht if i < groups.count - 1
      k = xor(groups.last, k).hasht if i == 0
      k = xor(text_groups.first, k).hasht if i == groups.count - 1
      text_groups[i] = xor(group, k)
    end
    @text = text_groups.reverse.join.scan(/.{1,8}/).map{|n| n.to_i(2).chr}.join
  end

  def xor(t,k)
    t.chars.zip(k.chars).inject('') { |c, (s1, s2)|
      c << (s1.to_i ^ s2.to_i).to_s
    }
  end

  def show_groups
    puts
    puts self.byte_groups.count

    puts
    puts self.byte_groups.map{|i| i.to_i(2).to_s(16).scan(/.{1,8}/).join(' ')}
  end
end
