# I V X L C D M

def numerate number
  m = number / 1000
  number = number % 1000
  if number >= 500
    d = 1
    number = number - 500
  end
  c = number / 100
  number = number % 100
  if number >= 50
    l = 1
    number = number - 50
  end
  x = number / 10
  number = number % 10
  if number >= 5
    v = 1
    number = number - 5
  end
  i = number
  puts 'M' * m.to_i + 'D' * d.to_i + 'C' * c.to_i + 'L' * l.to_i + 'X' * x.to_i + 'V' * v.to_i + 'I' * i.to_i
end

num = rand(3200)
puts num
numerate num
numerate 1992