# load 'integer.rb'
load 'string.rb'
load 'array.rb'

class Integer
  def rand_chrs
    times.map{ (' '..'~').to_a.sample }.join
  end
end

###############################
# Actually Encode Some Stuffs #
###############################
puts '[e]ncode/[u]nencode/[t]est?'
choice = gets.chomp.downcase
##########
# Encode #
##########
if choice == 'e'
  puts '[f]ile or [c]opied/cut text?'
  choice = gets.chomp.downcase
  if choice == 'c'
    result = []
    piece = ''
    puts 'enter your message. enter only \'f\' to finish input'
    while piece.chomp != 'f'
      piece = gets
      result << piece unless piece.chomp == 'f'
    end
    message = result.join
  elsif choice == 'f'
    puts 'Enter full file path'
    filename = gets.chomp
    message = File.read filename
  else
    return 'not a valid option'
  end
  puts 'Enter a secret key'
  key = gets.chomp
  start = Time.new
  coded = message.encode(key)
  ending = Time.new
  puts "took #{ending - start} sec"
  puts
  if coded.length < 1000
    puts "\nEncoded Stuff:"
    puts coded
  end
  puts
  puts 'Save as?'
  filename = gets.chomp
  if !filename.empty?
    File.open filename, 'w' do |f|
      f.write coded
    end
    puts "\nEncoded Stuff saved to #{filename}"
  else
    puts 'File not saved'
  end
############
# Unencode #
############
elsif choice == 'u'
  puts '[f]ile or [c]opied/cut text?'
  choice = gets.chomp.downcase
  if choice == 'c'
    puts 'Enter your coded message'
    coded = gets.chomp
  elsif choice == 'f'
    puts 'Enter full file path'
    filename = gets.chomp
    coded = File.read filename
  else
    return 'not a valid option'
  end
  puts 'Enter the secret key'
  key = gets.chomp
  message = coded.unencode(key)
  puts
  puts "\nPlaintext"
  puts message
  puts
  puts 'Save as?'
  filename = gets.chomp
  if !filename.empty?
    File.open filename, 'w' do |f|
      f.write message
    end
    puts "\nPlaintext saved to #{filename}"
  else
    puts 'File not saved'
  end
########
# Test #
########
elsif choice == 't'
  puts '############'
  puts '#   Test   #'
  puts '############'
  puts
  key = 'something_secret'
  message = '______________'
  repeat = 1
  start = Time.new
  repeat.times do
    coded = message.encode(key)
    puts "\ncoded:         " + coded
    puts 'decoded:       ' + coded.to_s.unencode(key)
  end
  puts
  ended = Time.new
  puts "Encoded length: #{coded.length}"
  puts "Message length: #{message.length}"
  puts "Average time: #{(ended-start)/repeat} seconds"
  puts
  puts '############'
  puts '# End Test #'
  puts '############'
else
  puts 'not a valid option'
end
