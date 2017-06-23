require 'prime'

def pandigital_prime(num)
  (num.to_s.split('').map{|i|i.to_i}&(1..num.to_s.length).to_a).count == num.to_s.length && Prime.prime?(num)
end



(500000..(7654320/2)).each do |num|
  p (num*2+1) if pandigital_prime(num*2+1)
end
