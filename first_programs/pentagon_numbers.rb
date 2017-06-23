def pent(n)
  n*(3*n-1)/2
end

def pent?(p)
  ((1+Math.sqrt(1+24*p))/6)%1 == 0
end

(1..10000).each do |n|
  print '.' if n%100 == 0
  ((n+1)..10001).each do |x|
    result = pent?(pent(n)+pent(x)) 
    if result
      result = pent?(pent(x)-pent(n))
    end
    if result
      puts "#{pent(n)}   #{pent(x)}"
    end
  end
end

puts
puts
puts

(1..225).each do |p|
  puts "#{pent?(p)}       --    #{p}" if pent?(p)
end

puts 1560090-7042750