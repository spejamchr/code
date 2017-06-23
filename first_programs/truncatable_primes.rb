require 'prime'

class Integer
  def truncatable_prime
    return false unless Prime.prime?(self)
    array = self.to_s.split('').map{|i|i.to_i}
    while array.count > 1
      array.pop
      return false unless Prime.prime?(array.join.to_i)
    end
    array = self.to_s.split('').map{|i|i.to_i}
    while array.count > 1
      array.shift
      return false unless Prime.prime?(array.join.to_i)
    end
    return true
  end
end

results = []
i = 11
while results.count < 11
  p (i.to_s + '*') if i % 100 == 0
  verd = i.truncatable_prime
  results << i if verd
  p i if verd
  i += 2
end

p results
p results.inject(:+)