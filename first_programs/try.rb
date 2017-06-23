def resilience(d)
  r = 0
  (1...d).each do |n|
    frac = n.to_r/d.to_r
    if frac.denominator == d
      r += 1
    end
  end
  r.to_r/(d-1).to_r
end

puts resilience(64696)

class Foo
  def initialize
    @this = nil
    @that = nil
    @those = nil
  end
  
  def this
    @this ||=
      if @that
        that*2
      elsif @those
        those*3
      end
  end
  
  def that
    @that ||=
      if @this
        this/2.0
      elsif @those
        those*(3.0/2.0)
      end
  end
  
  def those
    @those ||=
      if @this
        this/3.0
      elsif @that
        that*(2.0/3.0)
      end
  end
  
  def this= that
    @this = that
  end
  
  def that= this
    @that = this
  end
  
  def those= these
    @those = these
  end
  
end