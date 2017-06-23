n3=1
n2=1
n1=1

i=2
while n3 < 10**999
  n3 = n1 + n2
  n1 = n2
  n2 = n3
  i+=1
end

puts n3
puts i
