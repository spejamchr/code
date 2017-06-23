f0 = 1
f1 = 1
fib = 1
count = 1
while fib/(10**999) <1
  puts fib.to_s.split(//).count
  
  fib = f0+f1
  f0 = f1
  f1 = fib
  count += 1
  puts count
  puts
end
puts
puts fib.to_s.split(//).count
puts fib
