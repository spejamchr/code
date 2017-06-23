amount = 2
num = 2
spiral = [[1]]
while amount <= 10
  spiral.push((num..(num+amount-1)).to_a)
  num += amount
  spiral.push((num..(num+amount-1)).to_a)
  num += amount
  spiral.push((num..(num+amount-1)).to_a)
  num += amount
  spiral.push((num..(num+amount-1)).to_a)
  num += amount
  amount += 2
end

(0..20).each do |i|
  puts spiral[i].to_s
end