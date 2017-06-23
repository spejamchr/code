puts 'Starting year?'
first = gets.chomp.to_i
puts 'Ending year?'
finish = gets.chomp.to_i
total = 0
start = first
puts 'These are all leap years:'
while start < finish
  if start % 100 == 0
    if start % 400 == 0
      total = total + 1
      puts start
    end
  else
    if start % 4 == 0
      total = total + 1
      puts start
    end
  end
  start = start + 1
end
puts 'There are ' + total.to_s + ' leap years'
puts 'between ' + first.to_s + ' and ' + finish.to_s + '.'