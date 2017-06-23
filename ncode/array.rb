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

  def ungroup
    grouped_array = self
    count = grouped_array.count
    remaining = grouped_array.last[-1].to_i
    grouped_array[count-1] = grouped_array.last.split('').first(remaining).join
    (0...(count-1)).each do |i|
      grouped_array[i] = grouped_array[i].split('').first(grouped_array[i].length-1).join
    end
    grouped_array.join
  end

  def scatter
    grouped = self
    (0...grouped.count).each do |num|
      array_a, array_b = [grouped[num].split(''), grouped[(num+1)%grouped.count].split('')]

      array_b << array_a.shift(SWAP)
      array_a << array_b.shift(SWAP)
      array_b << array_b.shift(SWAP)

      grouped[num], grouped[(num+1)%grouped.count] = [array_a.join, array_b.join]
    end
    grouped
  end

  def anti_scatter
    grouped = self
    (-1...(grouped.count-1)).each do |num|
      array_a, array_b = [grouped[num].split(''), grouped[num+1].split('')]

      array_a.unshift(array_a.pop(SWAP))
      array_b.unshift(array_a.pop(SWAP))
      array_a.unshift(array_b.pop(SWAP))

      grouped[num], grouped[num+1] = [array_a.join, array_b.join]
    end
    grouped
  end

  def zipcode
    grouped = self
    max = grouped.count - 1
    (0..max).each do |i|
      grouped[i] = grouped[i].code(grouped[(i+1) % grouped.count].mix.to_s)
    end
    grouped.scatter
  end

  def unzipcode
    grouped = self.reverse.anti_scatter
    max = grouped.count - 1
    (0..max).each do |i|
      grouped[i] = grouped[i].code(grouped[i-1].mix.to_s)
    end
    grouped.reverse
  end

end