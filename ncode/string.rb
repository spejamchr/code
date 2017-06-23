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

  def code(key)
    key_array = key.split('')
    plaintext_array = self.split('')
    combined_key = key.mix * plaintext_array.count
    combined_key_array = combined_key.to_s.split('')
    plaintext_array.each_with_index.map{|letter,i| letter.transform(
      key_array[i % (key_array.length)],
      (combined_key_array[i % (combined_key_array.length)].
      + combined_key_array[(i+1) % (combined_key_array.length)]).to_i
    ) }.join
  end

  def group(encode=:no)
    groups = []
    coded_array = self.split('')
    @char = (encode == :encode ? 1 : 0)
    timer = (coded_array.count/(GROUP_LENGTH-@char))
    timer.times do
      @ending_char = 1.rand_chrs if encode == :encode
      groups << (coded_array.shift(GROUP_LENGTH-@char).join + @ending_char.to_s)
    end
    remaining = coded_array.count
    filler = (GROUP_LENGTH-1-remaining).rand_chrs
    groups << (coded_array.join + filler + remaining.to_s)
    groups
  end

  def supercode(key)
    coded = self.code(key)
    grouped = coded.group(:encode)
    ZIP.times{ grouped = grouped.zipcode}
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

  def replace(anti=false)
    string = self
    REPLACEMENTS.each do |i,k|
      anti ? string.gsub!(k,i) : string.gsub!(i,k)
    end
    string
  end

  def clean
    self.replace.split('').
    map{|letter| (" ".."~").to_a.include?(letter) ? letter : "X"}.join
  end

  def encode(key)
    if self.length < GROUP_LENGTH
      (GROUP_LENGTH-self.length).times{ self << ' ' }
    end
    encoded = self.clean
    SUPERENCODE.times do
      encoded = encoded.supercode(key)
    end
    encoded
  end

  def unencode(key)
    text = self
    SUPERENCODE.times do
      text = text.superuncode(key)
    end
    text.replace(true)
  end

  def mix
    mixed = self.split('').each_with_index.map{ |letter,i| letter.transform(letter,(i+57).to_s)}.join + ' ~'
    mixed = mixed.split('').map {|c| c.ord}.xor_array.join.to_i**2
    mixed = mixed / (mixed.to_s.length**4)
    mixed = mixed / (mixed.to_s.length + self.to_s.length)
    mixed = mixed * (mixed.to_s.length**5)
  end
end