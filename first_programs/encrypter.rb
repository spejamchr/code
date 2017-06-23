class String

  def encrypt
    self.tr!(" -~", "!-~ ")
  end

  def decrypt
    self.tr!("!-~ ", " -~")
  end
end

class Integer
  def rand_chrs
    o = [(' '..'~')].map { |i| i.to_a }.flatten
    (0...self).map { o[rand(o.length)] }.join
  end
end

class Range
  def shift
    self.map{|i| i.decrypt}.join
  end
end

class String
  def shift
    (self[0]..self[self.length-1]).shift
  end
end

name = "Spencer Christiansen, jc.spencer92@gmail.com"

code = name.encrypt

puts code

puts code.decrypt
puts (' '..'~').to_a.join

puts


puts (' '..'~').shift

range = (' '..'~')
puts range.class
puts
3.times do
  puts range
  range = range.shift
end


puts 'S'.xor('F')
puts 'p'.xor('a',20)
puts 'e'.xor('t',3)
puts 'n'.xor('h',8)
puts 'c'.xor('e',5)
puts 'e'.xor('r',9)
puts 'r'.xor('s',7)
puts
puts 'F'.xor('%')
puts 'a'.xor('8',20)
puts 't'.xor('A',3)
puts 'h'.xor('?',8)
puts 'e'.xor('P',5)
puts 'r'.xor('=',9)
puts 's'.xor('1',7)
