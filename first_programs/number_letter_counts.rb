ARRA = {1 => 'one',
        2 => 'two',
        3 => 'three',
        4 => 'four',
        5 => 'five',
        6 => 'six',
        7 => 'seven',
        8 => 'eight',
        9 => 'nine',
       10 => 'ten',
       11 => 'eleven',
       12 => 'twelve',
       13 => 'thirteen',
       14 => 'fourteen',
       15 => 'fifteen',
       16 => 'sixteen',
       17 => 'seventeen',
       18 => 'eighteen',
       19 => 'nineteen',
       20 => 'twenty',
       30 => 'thirty',
       40 => 'forty',
       50 => 'fifty',
       60 => 'sixty',
       70 => 'seventy',
       80 => 'eighty',
       90 => 'ninety',
      100 => 'hundred',
     1000 => 'thousand'}


def num_to_word num
  if num < 20
    return ARRA[num]
  elsif num == 1000
    return ARRA[1] + ARRA[1000]
  elsif num < 100
    tens = num/10*10
    return ARRA[tens] + ARRA[num-tens].to_s
  else
    hundreds = ARRA[num/100]
    rest = 'and' + num_to_word(num-(num/100*100)).to_s
    rest = nil if (num-(num/100*100)) == 0
    return hundreds.to_s + 'hundred' + rest.to_s
  end
end
sum = 0
(1..1000).each{|d| sum += num_to_word(d).length}
puts sum
puts num_to_word 100