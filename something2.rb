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

require 'prime'

INSPECT = true
CODE = false

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
      if self == 1
        number = rand(1..4)
        if number == 1
          return 2
        elsif number == 2
          return 3
        elsif number == 3
          return 5
        elsif number == 4
          return 7
        end
      else
        number = rand((10**(self-2))..(10**(self-1)-1))*10+1
      end
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
    number = rand((10**(self-1))..(10**self-1))
    return number
  end
end

class String

  SUPERENCODE = 1
  ZIP = 3
  GROUP_LENGTH = 10
  REPLACEMENTS = { "\n"=>"</\"pq\"\\>",  # </"pq"\>
                   "\t"=>"</\"tt\"\\>",  # </"tt"\>
                   "“" =>"</\"o\"\"\\>", # </"o""\>
                   "”" =>"</\"c\"\"\\>", # </"c""\>
                   "‘" =>"</\"o'\"\\>",  # </"o'"\>
                   "’" =>"</\"c'\"\\>",  # </"c'"\>
                 }

  @@characters = (' '..'~').to_a
  @@table = [] << @@characters.reverse
  (@@characters.count-1).times {@@table << @@characters.rotate!(-1).reverse}

  def transform(char,extra_key)
    table = @@table.rotate(extra_key.to_i)
    table[@@characters.index(self)][@@characters.index(char)]
  end

  if CODE
    def code(key)
      key_array = key.split('')
      plaintext_array = self.split('')
      combined_key = key.mix * plaintext_array.count
      combined_key_array = combined_key.to_s.split('')

      #puts "1 code: " + combined_key_array.join if INSPECT
      #puts "2 code: " + plaintext_array.join if INSPECT

      plaintext_array.each_with_index.map{|letter,i| letter.transform(
        key_array[i % (key_array.length)],
        (combined_key_array[i % (combined_key_array.length)].
        + combined_key_array[(i+1) % (combined_key_array.length)]).to_i
      ) }.join
    end
  else
    def code(key)
      self
    end
  end

  def group(encode=:no)
    groups = []
    coded_array = self.split('')
    if encode == :encode
      timer = (coded_array.count/(GROUP_LENGTH-1)) if (GROUP_LENGTH-1) < coded_array.count
    else
      timer = (coded_array.count/GROUP_LENGTH) if GROUP_LENGTH < coded_array.count
    end
    timer ||= 1
    if encode == :encode
      timer.times do
        groups << (coded_array.shift(GROUP_LENGTH-1).join + 1.rand_chrs)
      end
    else
      timer.times do
        groups << coded_array.shift(GROUP_LENGTH).join
      end
    end
    remaining = coded_array.count
    filler = (GROUP_LENGTH-1-remaining).rand_chrs
    # filler = ('a'..'z').first(9-remaining).join
    groups << (coded_array.join + filler + remaining.to_s)
    puts "group: " + groups.inspect if INSPECT
    groups
  end

  def supercode(key)
    puts "0 supercode: " + {self=>key}.inspect if INSPECT
    coded = self.code(key)
    puts "1 supercode: " + coded.inspect if INSPECT
    grouped = coded.group(:encode)
    ZIP.times{ grouped = grouped.zipcode}
    puts "2 supercode: " + grouped.join.inspect if INSPECT
    grouped.join
  end

  def superuncode(key)
    grouped = self.group
    if self.length % GROUP_LENGTH == 0
      grouped = grouped.first(grouped.count - 1)
    end
    ZIP.times{ grouped = grouped.unzipcode }
    grouped.ungroup.code(key)
  end

  def replace
    this = self
    REPLACEMENTS.each do |i,k|
      this.gsub!(i,k)
    end
    puts "replace: " + this.inspect if INSPECT
    this
  end

  def clean
    self.replace.split('').
    map{|letter| (" ".."~").to_a.include?(letter) ? letter : "X"}.join
  end

  def un_replace
    that = self
    REPLACEMENTS.each do |i,k|
      that.gsub!(k,i)
    end
    that
  end

  def encode(key)
    if self.length < GROUP_LENGTH
      (GROUP_LENGTH-self.length).times{ self << ' ' }
    end
    encoded = self.clean
    SUPERENCODE.times do
      encoded = encoded.supercode(key)
    end
    puts "encode: " + encoded.inspect if INSPECT
    encoded
  end

  def unencode(key)
    text = self
    SUPERENCODE.times do
      text = text.superuncode(key)
    end
    text.un_replace
  end

  def to_num_array
    self.split('').map {|c| c.ord}
  end

  def mix
    mixed = self.split('').each_with_index.map{ |letter,i| letter.transform(letter,(i+57).to_s)}.join
    mixed = mixed + ' ~'
    mixed = mixed.to_num_array.xor_array.join.to_i**2
    mixed = mixed / (mixed.to_s.length)
    mixed = mixed / (mixed.to_s.length + self.to_s.length)
    mixed = mixed * (mixed.to_s.length)
  end
end

class Array
  SWAP = 3


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
    grouped_array[count-1] = grouped_array.last.split('').first(remaining).join
    (0...(count-1)).each do |i|
      grouped_array[i] = grouped_array[i].split('').first(grouped_array[i].length-1).join
    end
    grouped_array.join
  end

  def scatter
    grouped = self
    (1...grouped.count).each do |num|
      array_a = grouped[num-1].split('')
      array_b = grouped[num].split('')
      array_b << array_a.shift(SWAP)
      array_a << array_b.shift(SWAP)
      array_b << array_b.shift(SWAP)
      grouped[num-1] = array_a.join
      grouped[num] = array_b.join
    end
    grouped
  end

  def anti_scatter
    grouped = self
    (1...grouped.count).each do |num|
      array_a = grouped[num-1].split('')
      array_b = grouped[num].split('')
      array_a.unshift(array_a.pop(SWAP))
      array_b.unshift(array_a.pop(SWAP))
      array_a.unshift(array_b.pop(SWAP))
      grouped[num-1] = array_a.join
      grouped[num] = array_b.join
    end
    grouped
  end

  def zipcode
    i = 0
    grouped = self.anti_scatter
    max = grouped.count - 2
    while i <= max
      grouped[i] = grouped[i].code(grouped[i+1].mix.to_s)
      i += 1
    end
    grouped[max + 1] = grouped[max + 1].code(grouped[0].mix.to_s)

    grouped = grouped.scatter
    puts "zipcode: " + grouped.inspect if INSPECT
    grouped
  end


  def unzipcode
    i = 1
    grouped = self
    grouped = grouped.reverse
    grouped = grouped.anti_scatter
    max = grouped.count - 1
    grouped[0] = grouped[0].code(grouped[max].mix.to_s)
    while i <= max
      grouped[i] = grouped[i].code(grouped[i-1].mix.to_s)
      i += 1
    end
    result = grouped.scatter.reverse
    puts "unzipcode: " + result.inspect if INSPECT
    result
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
  ##########
  # Encode #
  ##########
  if choice == 'e'
    puts '[f]ile or [c]opied/cut text?'
    choice = gets.chomp.downcase
    if choice == 'c'
      result = []
      piece = ''
      puts "enter your message. enter only 'f' to finish input"
      while piece.chomp != 'f'
        piece = gets
        result << piece unless piece.chomp == "f"
      end
      message = result.join
    elsif choice == 'f'
      puts "Enter full file path"
      filename = gets.chomp
      message = File.read filename
    else
      "not a valid option"
    end
    puts "Enter a secret key"
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
    puts "Save as?"
    filename = gets.chomp
    if !filename.empty?
      File.open filename, 'w' do |f|
        f.write coded
      end
      puts "\nEncoded Stuff saved to #{filename}"
    else
      puts "File not saved"
    end
  ############
  # Unencode #
  ############
  elsif choice == 'u'
    puts '[f]ile or [c]opied/cut text?'
    choice = gets.chomp.downcase
    if choice == 'c'
      puts "Enter your coded message"
      coded = gets.chomp
    elsif choice == 'f'
      puts "Enter full file path"
      filename = gets.chomp
      coded = File.read filename
    else
      "not a valid option"
    end
    puts "Enter the secret key"
    key = gets.chomp
    message = coded.unencode(key)
    puts
    puts "\nPlaintext"
    puts message
    puts
    puts "Save as?"
    filename = gets.chomp
    if !filename.empty?
      File.open filename, 'w' do |f|
        f.write message
      end
      puts "\nPlaintext saved to #{filename}"
    else
      puts "File not saved"
    end
  ########
  # Test #
  ########
  elsif choice == 't'
    puts "########"
    puts "# Test #"
    puts "########"
    puts
    key = "something_secret"
    message = "______________________________________________________"
    repeat = 1
    start = Time.new
    repeat.times do
      coded = message.encode(key)
      puts "\ncoded:\n" + coded
      puts "decoded:\n" + coded.to_s.unencode(key)
    end
    puts
    ended = Time.new
    puts "Encoded length: #{coded.length}"
    puts "Message length: #{message.length}"
    puts "Average time: #{(ended-start)/repeat} seconds"
    puts
    puts "############"
    puts "# End Test #"
    puts "############"
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
  seed = [2]
  n = 3
  while n < 292680
    i = 0
    while i < (seed.count - 1) && (n % seed[i] != 0)
      i += 1
    end
    if n % seed[i] != 0
      seed << n
    end
    n += 2
  end
  ending = Time.new
  puts seed.join(' ')
  puts "This took #{ending - start} seconds"
end


if false
  start = Time.new
  seed = [2,3]

  3.times do
    array = Array.new(seed)
    some_primes = ((array.max)..(array.max**2)).step(2).to_a.map do |number|
      testing = true
      i = 0
      while testing && i < seed.count
        testing = (number % seed[i] != 0)
        i += 1
      end
      if testing
        number
      end
    end
    primes = (seed + some_primes.compact)
    seed = primes
  end

  puts "beginning fun"
  array = Array.new(seed.first(1000))
  puts seed.count
  steps = 10000
  interval = ((array.max**2)-(array.max+1))/steps
  load = 0.0
  some_primes = ((array.max+1)..(array.max**2)).to_a.map do |number|
    testing = true
    i = 0
    while testing && i < seed.count && seed[i]**2 <= number
      testing = (number % seed[i] != 0)
      i += 1
    end
    if number % interval == 0
      load += 1.0
      print "\r#{(load*(100.0/steps)).round(3)}%"
    end
    if testing
      number
    end
  end
  primes = (seed + some_primes.compact)
  ending = Time.new
  puts
  puts primes.count.to_s + " primes were found"
  filename = "many_primes.txt"
  File.open filename, 'w' do |f|
    f.write primes.join(' ')
  end

  puts "took #{ending - start} sec"
  puts "last 10 primes = #{primes.last(10)}"
  puts 'The square of the biggest prime is: ' + (primes.last**2).to_s
  puts 'The sum of all these primes is: ' + (primes.inject(:+)).to_s

  puts
  if false
    number = 4870847
    start = Time.new
    is_prime = true
    i = 0
    while is_prime && primes[i]**2 <= number
      is_prime = (number % primes[i] != 0)
      i += 1
    end
    ending = Time.new
    puts "#{number} is prime?"
    puts is_prime
    puts "took #{ending - start} seconds"

    start = Time.new
    puts Prime.prime?(number)
    ending = Time.new
    puts "took #{ending - start} seconds"
  end
end
