class Integer
  def rn
    num = self
    roman = roman.to_s + 'M' * (num/1000)
    num = num % 1000
    if num >= 900
      roman = roman + 'CM'
      num = num - 900
    elsif num >= 500
      roman = roman + 'D'
      num = num - 500
    elsif num >= 400
      roman = roman + 'CD'
      num = num - 400
    end
  
    roman = roman + 'C' * (num/100)
    num = num % 100
    if num  >= 90
      roman = roman + 'XC'
      num = num - 90
    elsif num >= 50
      roman = roman + 'L'
      num = num - 50
    elsif num >= 40
      roman = roman + 'XL'
      num = num - 40
    end
  
    roman = roman + 'X' * (num/10)
    num = num % 10
    if num >= 9
      roman = roman + 'IX'
      num = num - 9
    elsif num >= 5
      roman = roman + 'V'
      num = num - 5
    elsif num >= 4
      roman = roman + 'IV'
      num = num - 4
    end
  
    roman = roman + 'I' * num
    puts roman
  end
end

1992.rn
1994.rn
4.rn
44.rn
1699.rn
1899.rn
1499.rn
3838.rn
3333.rn
3888.rn

# 1992 = MCMXCII
# 1999 = MCMXCIX
# 4    = IV
# 44   = XLIV
# 1699 = MDCXCIX
# 1899 = MDCCCXCIX
# 1499 = MCDXCIX