puts 'What year were you born in?'
year = gets
puts 'What month were you born in (in numerals)?'
month = gets
puts 'What day of the month were you born on?'
day = gets
birthday = Time.local(year, month, day)
now = Time.new
age = ((now - birthday)/(60*60*24*365)).to_i
age.times do puts "SPANK!"
end