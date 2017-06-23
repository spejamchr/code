load 'writer.rb'

file_names = Dir["ready/*.txt"]
writer = Writer.new
file_names.each do |fn|
  writer.add_text_from_filename(fn)
end

puts writer.essay
