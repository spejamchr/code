puts 'Enter names, please, and I will put them in alphabetical order.'
names = []
entry = ' '
while entry != ''
  entry = gets.chomp
  names.push entry
end
goodlist = []
names.each do |name|
  goodlist.push name.capitalize
end
puts 'Here are the names in alphabetical order:'
puts goodlist.sort