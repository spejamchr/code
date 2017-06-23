bottles = 99
while true
  puts bottles.to_s + ' bottles of Sprite on the wall!'
  puts bottles.to_s + ' bottles of Sprite!'
  puts 'Take one down, pass it around!'
  bottles = bottles - 1
  if bottles > 1
    puts bottles.to_s + ' bottles of Sprite on the wall!'
    puts ''
  else
    puts '1 bottle of Sprite on the Wall!'
    puts ''
    break
  end
end
puts '1 bottle of Sprite on the wall!'
puts '1 bottle of Sprite!'
puts 'Take it down, pass it around!'
puts 'No more bottles of Sprite on the wall!'