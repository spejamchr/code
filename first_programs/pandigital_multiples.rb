class Integer
  def con_pro(array)
    array.map{|i| self*i}.join.to_i
  end
  
  def pandigital
    return false unless self.to_s.length == 9
    (self.to_s.split('').map{|i|i.to_i}&[1,2,3,4,5,6,7,8,9]).count == 9
  end
end

results = []
(3..9999).each do |i|
  max = 6 - i.to_s.length
  (2..max).each do |j|
    array = (1..j).to_a
    results << i.con_pro(array) if i.con_pro(array).pandigital
  end
end

p results
p results.max