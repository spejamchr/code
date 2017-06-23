def profile block_description, &block
  profiling_on = false
  if profiling_on
    start_time = Time.new
    block[]
    duration = Time.new - start_time
    puts "#{block_description}: #{duration} seconds"
  else
    block[]
  end
end