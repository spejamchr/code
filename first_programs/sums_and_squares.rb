def sum_squares num
  numbers = (1..num).to_a
  squares = []
  numbers.each {|n| squares.push(n**2)}
  sum = 0
  squares.each {|n| sum += n}
  return sum
end

puts sum_squares 10

def square_sums num
  numbers = (1..num).to_a
  sum = 0
  numbers.each {|n| sum += n}
  return sum**2
end

puts square_sums 10

def difference num
  square_sums(num) - sum_squares(num)
end

puts difference 100