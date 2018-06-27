load 'writer.rb'

file_names = Dir["ready/*.txt"]

writer = Writer.new
starttime = Time.now
file_names.each do |fn|
  puts "Adding #{fn}"
  writer.add_text_from_filename(fn)
end
puts "Took #{Time.now - starttime}s"

puts writer.essay
