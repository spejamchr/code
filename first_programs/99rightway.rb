def english_number number
  if number < 0
    return 'Please enter a number that isn\'t negative.'
  end
  if number == 0
    return 'zero'
  end
  
  num_string = ''
  
  ones_place = ['one',       'two',      'three',
                'four',      'five',     'six',
                'seven',     'eight',    'nine']
  tens_place = ['ten',       'twenty',   'thirty',
                'forty',     'fifty',    'sixty',
                'seventy',   'eighty',   'ninety']
  teenagers =  ['eleven',    'twelve',   'thirteen',
                'fourteen',  'fifteen',  'sixteen',
                'seventeen', 'eighteen', 'nineteen']
  bignumbers = [' thousand',   ' million',     ' billion',
                ' trillion',   ' quadrillion', ' quintillion',
                ' sextillion', ' septillion',  ' octillion']
                  
  left = number
  
  while left >= 1000
    tensss = ((left.to_s.length) - 1) / 3
    write = left / (10 ** (tensss * 3))
    left = left - write * (10 ** (tensss * 3))
    if write > 0
      bigness = english_number write
      num_string = num_string + bigness + bignumbers [tensss-1]
      if left > 0
        num_string = num_string + ' '
      end
    end
  end
  
  write = left / 100
  left = left - write * 100
  
  if write > 0
    hundreds = english_number write
    num_string = num_string + hundreds + ' hundred'
    if left > 0
      num_string = num_string + ' '
    end
  end
  
  write = left / 10
  left = left - write * 10
  if write > 0
    if ((write == 1) and (left > 0))
      num_string = num_string + teenagers [left - 1]
      left = 0
    else
      num_string = num_string + tens_place [write - 1]
    end
    if left > 0
      num_string = num_string + '-'
    end
  end
  
  write = left
  left = 0
  if write > 0
    num_string = num_string + ones_place [write -1]
  end
  num_string
end



bottles = 9999
while true
  puts (english_number (bottles)).to_s.capitalize + ' bottles of Sprite on the wall!'
  puts (english_number (bottles)).to_s.capitalize + ' bottles of Sprite!'
  puts 'Take one down, pass it around!'
  bottles = bottles - 1
  if bottles > 1
    puts (english_number (bottles)).to_s.capitalize + ' bottles of Sprite on the wall!'
    puts ''
  else
    puts 'One bottle of Sprite on the Wall!'
    puts ''
    break
  end
end
puts 'One bottle of Sprite on the wall!'
puts 'One bottle of Sprite!'
puts 'Take it down, pass it around!'
puts 'No more bottles of Sprite on the wall!'