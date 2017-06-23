class Array
  
  def first_1
    first = nil
    (1..(self.count-1)).each do |i|
      first = self[i-1] if self[i-1] < self[i]
    end
    first
  end
  
  def second(first)
    second = self.count
    start = self.index(first)
    (start..(self.count-1)).each do |i|
      second = self[i] if self[i] > first && self[i] < second
    end
    second
  end
  
  def switch(first,second)
    array = self
    this = array.index(first)
    array[this] = :mid
    array[array.index(second)] = first
    array[array.index(:mid)] = second
    {array: array, this: this}
  end
  
  def next_p
    first = self.first_1
    second = self.second(first)
    switch(first,second).sorted
  end
  
end

class Hash
  
  def sorted
    first = self[:array].first(self[:this]+1)
    last = (self[:array] - first).sort
    first + last
  end
  
end

array = [0,1,2,3,4,5,6,7,8,9]
999999.times do
  p array
  array = array.next_p
end
p array
