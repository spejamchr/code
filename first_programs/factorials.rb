class Integer
  def factorial
    if self < 0
      return "You can't take the factorial of a negative number!"
    elsif self <= 1
      return 1
    end
    self * (self-1).factorial
  end
end
puts 4.factorial
puts (-2).factorial
#puts 0.3.factorial ---Doesn't work; is a Float, not an Integer.
puts 10.factorial