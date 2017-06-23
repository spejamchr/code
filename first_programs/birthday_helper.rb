birthdates = {}
births = []
names = []
Dir.chdir '/Users/spencer/desktop/text'
filename = 'Birthdays.txt'
list = File.read filename
list.each_line do |line|
  births.push line.chomp.split ','
end
births.each do |entry|
  names = names + entry
end
number = 0
while names.length >= number
  birthdates [names[number]] = names[number + 1]
  number = number + 2
end

puts "Whose birthday should I find for you? First and last names, please."
response = gets.chomp
puts "#{response} was born on: #{birthdates[response]}"