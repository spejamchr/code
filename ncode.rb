INSPECT = false
CODE = false

class Integer
  def rand_chrs
    o = (' '..'~').to_a
    (0...self).map { o[rand(o.length)] }.join
  end
end

class String

  SUPERENCODE = 1
  ZIP = 5
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
      key_array = key.mix.to_s.split('')
      plaintext_array = self.split('')
      combined_key = key.mix * plaintext_array.count
      combined_key_array = combined_key.to_s.split('')

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
    puts "group:       " + groups.inspect + "\n\n" if INSPECT
    groups
  end

  def supercode(key)
    puts "0 supercode: " + {self=>key}.inspect if INSPECT
    coded = self.code(key)
    puts "1 supercode:  " + coded.inspect if INSPECT
    grouped = coded.group(:encode)
    ZIP.times{ grouped = grouped.zipcode}
    puts "\n2 supercode:  " + grouped.join.inspect if INSPECT
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
    puts "replace:      " + this.inspect if INSPECT
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
    puts "encode:       " + encoded.inspect if INSPECT
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
    mixed = self.split('').each_with_index.map{ |letter,i| letter.transform(letter,(self[i-1].ord).to_s)}.join
    mixed = mixed + ' ~'
    mixed = mixed.to_num_array.xor_array.join.to_i**2
    mixed = mixed / (mixed.to_s.length)
    mixed = mixed / (mixed.to_s.length + self.to_s.length)
    mixed = mixed * (mixed.to_s.length)
  end
end

class Array
  SWAP = 1


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
    # array_a = grouped.last.split('')
    # array_b = grouped.first.split('')
    # array_b << array_a.shift(SWAP)
    # array_a << array_b.shift(SWAP)
    # array_b << array_b.shift(SWAP)
    # grouped[0] = array_b.join
    # grouped[grouped.count-1] = array_a.join

    (0...grouped.count).each do |num|
      array_a = grouped[num].split('')
      array_b = grouped[(num+1)%grouped.count].split('')

      # array_b << array_a.pop(SWAP)
      # array_b.flatten!
      # array_a << array_b.shift(SWAP)
      # array_a.flatten!
      # array_b.unshift(array_b.pop(SWAP))

      array_b << array_a.shift(SWAP)
      array_a << array_b.shift(SWAP)
      array_b << array_b.shift(SWAP)


      grouped[num] = array_a.join
      grouped[(num+1)%grouped.count] = array_b.join
    end
    grouped
  end

  def anti_scatter
    grouped = self
    (-1...(grouped.count-1)).each do |num|
      array_a = grouped[num].split('')
      array_b = grouped[num+1].split('')

      array_a.unshift(array_a.pop(SWAP))
      array_b.unshift(array_a.pop(SWAP))
      array_a.unshift(array_b.pop(SWAP))

      grouped[num] = array_a.join
      grouped[num+1] = array_b.join
    end
    grouped
  end

  def zipcode
    i = 0
    grouped = self#.anti_scatter
    max = grouped.count - 2
    while i <= max
      grouped[i] = grouped[i].code(grouped[i+1].mix.to_s)
      i += 1
    end
    grouped[max + 1] = grouped[max + 1].code(grouped[0].mix.to_s)

    grouped = grouped.scatter
    puts "zipcode:     " + grouped.inspect if INSPECT
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
    result = grouped.reverse
    puts "unzipcode: " + result.inspect if INSPECT
    result
  end

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
      return "not a valid option"
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
      return "not a valid option"
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
    key = "hello"
    message = '______________________________________________________'
    repeat = 1
    start = Time.new
    (INSPECT ? 1 : repeat).times do
      puts "\noriginal:      " + message
      coded = message.encode(key)
      puts "coded:         " + coded
      puts "decoded:       " + coded.to_s.unencode(key)
    end
    unless INSPECT
      # 100.times do
#         a = 1.rand_chrs
#         puts "bad password:  " + coded.to_s.unencode(key.chomp(key[-1])+a) + ' --> ' + a
#       end
      messages = ["____________________", "___________________", "__________________", "_________________", "________________", "_______________", "______________", "_____________", "____________", "___________", "__________", "_________", "________", "_______", "______", "_____", "____", "___", "__", "_", ""]
      messages.each do |m|
        puts "original:      " + m
        coded = m.encode(key)
        puts "coded:         " + coded
      end
    end
    ended = Time.new
    puts
    puts "Encoded length: #{coded.length}"
    puts "Message length: #{message.length}"
    puts "Average time: #{(ended-start)/(INSPECT ? 1 : repeat)} seconds"
    puts
    puts "############"
    puts "# End Test #"
    puts "############"
  else
    puts "not a valid option"
  end
end
