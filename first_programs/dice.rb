class Die
  def initialize
    roll
  end
  def roll
    @number_showing = 1 + rand(6)
  end
  def showing
    @number_showing
  end
  def cheat(num)
    @number_showing = (num - 1) % 7 + 1
  end  
end

puts Die.new.showing