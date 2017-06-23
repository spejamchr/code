puts 'What is your first name?'
firstname = gets.chomp
puts 'What is your middle name?'
middlename = gets.chomp
puts 'What is your last name?'
lastname = gets.chomp
fulllength = firstname.length + middlename.length + lastname.length
fullname = firstname + ' ' + middlename + ' ' + lastname
puts 'Did you know that your name has ' + fulllength.to_s + ' letters'
puts 'in it, ' + fullname + '?'