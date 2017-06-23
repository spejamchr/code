def sequence n
  sequence = [0]
  (1..n).each do |d|
    sequence[d] = (sequence[d-1]**2 + 45) % 1000000007
  end
  sequence
end

puts sequence 6
  