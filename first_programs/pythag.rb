a = 2
b = 3
c = 5

while (a**2 + b**2 != c**2) || (a + b + c != 1000)
  while a+b+c != 1000
    if a+b+c < 1000
      this = rand(3)
      if this == 0
        a += 1
      elsif this == 1
        b += 1
      elsif this == 2
        c += 1
      end
    elsif a+b+c > 1000
      this = rand(2)
      if this == 0
        a -= 1
      elsif this == 1
        b -= 1
      elsif this == 2
        c -= 1
      end
    end
  end
  
  if a > b 
    a -= 1
    b += 1
  end
  if  b > c
    b -= 1
    c += 1
  end
  
  if a**2 + b**2 < c**2
    this = rand(2)
    if this == 0
      a += 1
    elsif this == 1
      b += 1
    end
    c -= 1
  elsif a**2 + b**2 > c**2
    this = rand(2)
    if this == 0
      a -= 1
    elsif this == 1
      b -= 1
    end
    c += 1
  end
end
puts
puts "a: #{a}, b: #{b}, c: #{c}"

puts a**2 + b**2
puts c**2
puts a + b + c

puts (a**2 + b**2 != c**2)
puts a * b * c