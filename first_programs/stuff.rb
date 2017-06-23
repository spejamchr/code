number = 1
start_time = Time.new
1000000.times do
  number = number * 2
end
puts number.to_s.length
processing_time = Time.new - start_time
puts
puts processing_time
