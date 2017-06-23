def chain(n)
  chain = [n]
  t = 0
  until t == 89 || t == 1
    chain << t = chain.last.to_s.split('').
      map{|t| t.to_i**2}.inject(:+)
  end
  chain.last
end

count = 0
start = Time.new
(1..10000000).each do |n|
  print '.' if n%1000 == 0
  this = chain n
  if this == 89
    count += 1
  end
end

puts "This took #{Time.new - start} seconds."
puts count
