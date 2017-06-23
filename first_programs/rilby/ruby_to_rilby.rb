load 'key.rb'

def parse_file file
  KEY.each do |key, sym|
    new_text = " #{key} "
    file.gsub! sym, new_text
  end
  file
end


puts 'Translate which file?'
file_name = gets.chomp

file = File.read file_name
file = parse_file file

puts 'Save as? (extension ".ril" will be added)'
file_name = gets.chomp
if !file_name.empty?
  file_name = file_name + '.ril'
  File.open file_name, 'w' do |f|
    f.write file
  end
  puts "\nPlaintext saved to #{file_name}"
else
  puts "File not saved"
end
