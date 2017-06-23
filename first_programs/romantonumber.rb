# 1992 = MCMXCII
# 1999 = MCMXCIX
# 4    = IV
# 44   = XLIV
# 1699 = MDCXCIX
# 1899 = MDCCCXCIX
# 1499 = MCDXCIX

def roman_to_integer roman
  numbers = {"I"=>1, "V"=>5, "X"=>10, "L"=>50, "C"=>100, "D"=>500, "M"=>1000}
  running_total = 0
  characters = roman.length - 1
  place = 0
  roman = roman.upcase
  while place <= characters
    if numbers[roman[place]] == nil
      puts "Not a true roman numeral."
      exit
    else
      if place == characters
        running_total = running_total + numbers[roman[place]]
        break
      else
        if numbers[roman[place]] >= numbers[roman[place + 1]]
          running_total = running_total + numbers[roman[place]]
        else
          running_total = running_total + (numbers[roman[place + 1]] - numbers[roman[place]])
          place = place + 1
        end
      end
      place = place + 1
    end
  end
  puts running_total
end

roman_to_integer "MCMXCIV"