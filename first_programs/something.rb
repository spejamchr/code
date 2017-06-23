################################
# I Should Improve This Stuffs #
################################
# Single-letter swapping needs #
# to change the encrypted text #
# as a whole. At the moment of #
# writing, single-letter swaps #
# only morph one letter in the #
# final encrypted text. Surely #
# I can improve! -Spencer J.C. #
################################

################################
# I've improved all that stuff #
################################

class Integer
  def rand_chrs
    o = (' '..'~').to_a
    (0...self).map { o[rand(o.length)] }.join
  end
  def rand_ints
    o = ('0'..'9').to_a
    (0...self).map { o[rand(o.length)] }.join
  end

  def digit_prime
    require 'prime'
    while true
      number = rand((10**(self-2))..(10**(self-1)-1))*10+1
      while true
        if Prime.prime?(number)
          return number
        elsif Prime.prime?(number+2)
          return number+2
        elsif Prime.prime?(number+6)
          return number+6
        elsif Prime.prime?(number+8)
          return number+8
        else
          number += 10
        end
      end
      if number.to_s.length == self
        return number
      end
    end
  end

  def digit_number
    number = rand(10**self)
    while number < 10**(self-1)
      number += 10**self
    end
    return number
  end
end

class String

  @@characters = (' '..'~').to_a
  @@table = [] << @@characters.reverse
  94.times {@@table << @@characters.rotate!(-1).reverse}

  def transform(char,extra_key)
    table = @@table
    table = table.rotate(extra_key.to_i)
    table[@@characters.index(self)][@@characters.index(char)]
  end

  def code(key)
    key_array = key.split('')
    my_key = 439134085439250639293
    combined_key = my_key * key.mix * self.length
    combined_key_array = combined_key.to_s.split('')
    coded = self.split('').each_with_index.map {|letter, i| letter.transform(
      key_array[i % (key_array.length)],
      (combined_key_array[i % (combined_key_array.length)] + combined_key_array[(i+1) % (combined_key_array.length)]).to_i
    ) }.join
    coded
  end
  
  def group(coded)
    groups = []
    coded_array = coded.split('')
    (coded_array.count/10).times do
      groups << coded_array.shift(10).join
    end
    remaining = coded_array.count
    filler = ('a'..'z').first(9-remaining)
    groups << (coded_array.join + filler.join + remaining.to_s)
  end
  
  def supercode(key)
    coded = self.code(key)
    grouped = group(coded)
    i = 0
    max = grouped.count - 2
    while i <= max
      grouped[i] = grouped[i].code(grouped[i+1])
      i += 1
    end
    
    grouped_reversed = grouped.reverse
    i = 0
    while i <= max
      grouped_reversed[i] = grouped_reversed[i].code(grouped_reversed[i+1])
      i += 1
    end
    grouped_reversed.reverse.join
  end
  
  def superuncode(key)
    grouped = group(self)
    if self.length % 10 == 0
      grouped = grouped.first(grouped.count - 1)
    end
    i = 1
    max = grouped.count - 1
    while i <= max
      grouped[i] = grouped[i].code(grouped[i-1])
      i += 1
    end
    i = 1
    grouped_reversed = grouped.reverse
    while i <= max
      grouped_reversed[i] = grouped_reversed[i].code(grouped_reversed[i-1])
      i += 1
    end
    grouped_reversed.reverse.ungroup.code(key)
  end
  
  def encode(key)
    self.supercode(key).supercode(key).supercode(key)
  end
  def unencode(key)
    self.superuncode(key).superuncode(key).superuncode(key)
  end

  def to_num_array
    self.split('').map {|c| c.ord}
  end

  def mix
    mixed = self.split('').each_with_index.map{ |letter,i| letter.transform(letter,(i+57).to_s)}.join
    mixed = mixed + ' ~'
    mixed = mixed.to_num_array.xor_array.join.to_i**2/27529
    mixed = mixed / (mixed.to_s.length)
    mixed = mixed / (mixed.to_s.length + self.to_s.length)
    mixed = mixed * (mixed.to_s.length)
  end
end

class Array
  def xor_array
    self.each_with_index.map do |item, i|
      if i == 0
        self.first ^ self.last
      else
        (1..i).inject(self[0]) {|total, value| total ^ self[value]}
      end
    end
  end

  def xor_array_d
    self.each_with_index.map do |item, i|
      if i == 0
        self.first ^ self[self.count-2]
      elsif i == 1
        item ^ self.last
      else
        (2..i).inject(self[0]) {|total, value| total ^ self[value]}
      end
    end
  end
  
  def ungroup
    grouped_array = self
    count = grouped_array.count
    remaining = grouped_array.last.split('').last.to_i
    last = grouped_array.last.split('').first(remaining)
    grouped_array[count-1] = last.join
    grouped_array.join
  end
end

class Symbol
  def split(arg)
    self.to_s.split(arg)
  end
  def mix
    self.to_s.mix
  end
end

###############################
# Test Transforming Algorithm #
###############################
if false
  start = Time.new
  100000.times do
    'A'.transform(' ',"4")
    'A'.transform('}',"5")
    'A'.transform('#',"45")
    'A'.transform('g',"9")
    'A'.transform('s',"87")
    'A'.transform(' ',"23")
    'A'.transform('}',"43")
    'A'.transform('#',"29")
    'A'.transform('g',"92")
    'A'.transform('s',"22")
  end
  ended = Time.new
  puts
  puts "This took #{ended-start} seconds"
  puts
end
###############################
# Actually Encode Some Stuffs #
###############################
if true
  
  
  puts '[e]ncode/[u]nencode/[t]est?'
  choice = gets.chomp.downcase
  if choice == 'e'
    puts "Enter a secret message"
    message = gets.chomp
    puts "Enter a secret key"
    key = gets.chomp
    coded = message.encode(key)
    puts
    puts "\nEncoded Stuff"
    puts coded
  elsif choice == 'u'
    puts "Enter your coded message"
    coded = gets.chomp
    puts "Enter a secret key"
    key = gets.chomp
    message = coded.unencode(key)
    puts
    puts "\nPlaintext"
    puts message
  elsif choice == 't'
    key = "secret"
    puts "Enter a secret message"
    message = gets.chomp
    puts
    puts
    puts "\nEncoded stuff:"
    puts
    start = Time.new
    coded = message.encode(key)
    puts [coded].to_s
    puts
    puts "unencoded:"
    puts [coded.to_s.unencode(key)].to_s
   ended = Time.new
    puts
    puts
    puts "This took #{ended-start} seconds"
  else
    puts "not a valid option"
  end
end
###############################
# Generate Quasirandom Primes #
###############################
if false
  require 'benchmark'

  ITERATIONS = 100

  def run(x, bench)
    bench.report("#{x} chars") do
      ITERATIONS.times do
        $prime = x.digit_prime
      end
    end
  end
  Benchmark.bm do |bench|
    100.times do
      run(10, bench)
    end
  end
end

if false
  x = 1
  while true
    start = Time.new
    $prime = x.digit_prime
    ended = Time.new
    time = (ended-start)
    puts "\n#{x}-digit prime:         #{$prime}"
    puts "Calculation time: #{time} seconds"
    puts "Found at #{Time.new}"
    x += 1
  end
end
###############################
# Generate Number from String #
###############################
if false
  puts '~'.mix
  puts ' '.mix
  puts 'a'.mix
  puts 'aa'.mix
  puts 'aaa'.mix
  puts 'Spences'.mix
  puts 'Rpencer'.mix
  puts 'Spemcer'.mix
  puts 'Zachary'.mix
  puts 'Heather'.mix
  puts 'Clarissa'.mix
  puts 'Mason'.mix
  puts 'James'.mix
  puts ' '.chr
  puts ''.mix
  puts ''.mix
  puts String.new.mix

end
###############################
# Other Stuffs You Want to Do #
###############################
if false
  start = Time.new
  seed = [2,3,5]
  array = Array.new(seed)
  ((array.max+1)..(array.max**2)).to_a.inject(array) do |result, number|
    testing = []
    seed.each {|trial| testing << (number % trial == 0) }.to_s
    result << number unless testing.include?('true')
    result
  end
  puts seed.count
  puts array.to_s

  ending = Time.new
  puts "took #{ending - start} sec"

  testing = []
  [2,3,5].each {|trial| testing << (8 % trial == 0) }.to_s
  puts testing.to_s.include?('true')


end
#
