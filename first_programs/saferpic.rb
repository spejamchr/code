Dir.chdir '/Users/spencer/Desktop/music mp3'
pic_names = Dir['/Users/spencer/Desktop/music/**/*.caf']

puts 'What would you like to call this batch?'
batch_name = gets.chomp
puts
print "Downloading #{pic_names.length} files:  "
pic_number = 1
pic_names.each do |name|
  print '.'
  while true
    new_name = if pic_number < 10
      "#{batch_name}0#{pic_number}.mp3"
    else
      "#{batch_name}#{pic_number}.mp3"
    end
    repeat = (File.exist? new_name)
    if repeat == true
      pic_number = pic_number + 1
    else
      break
    end
  end
  
  File.rename name, new_name
  pic_number = pic_number# + 1
end
puts
puts 'Done!'