# Solver
#
# Variables are represented by symbols # => :a, :b, :c
# Operations are functions # =>  *(:a,:b)
#
# Ex:
#   Solver.new(:z-(:x+:y)=:y-:w,:x)
#
module Operators
  def - arg
    Subtraction.new([self, arg])
  end

  def + arg
    Addition.new([self, arg])
  end

  def * arg
    Multiplication.new([self, arg])
  end

  def / arg
    Division.new([self, arg])
  end

  def == arg
    Equal.new([self,arg])
  end
end

class Symbol
  include Operators
  def value
    self
  end
end

class Operator < Array
  include Operators

  def to_s
    '(' + map(&:to_s).join(symbol.to_s) + ')'
  end

  def simple_operator?
    none? { |a| a.is_a?(Operator) }
  end

  def simplify
    if simple_operator?
      return value
    else
      return map { |a| a.respond_to?(:simplify) ? a.simplify : a }
    end
  end

  def value
    raise "Please define a #value method for #{self.class}"
  end

end

class Addition < Operator
  def value
    if include?(0)
      return find { |a| a != 0 }
    else
      return self
    end
  end

  def symbol
    :+
  end
end

class Subtraction < Operator
  def value
    return 0 if uniq.length == 1
    self
  end

  def symbol
    :-
  end
end

class Equal < Operator
  def value
    self
  end

  def symbol
    :==
  end

  def to_s
    map(&:to_s).join(symbol.to_s)
  end
end

class Multiplication < Operator
  def value
    self
  end

  def symbol
    :*
  end
end

class Division < Operator

  def value
    return 1 if uniq.length == 1
    self
  end

  def symbol
    :/
  end
end

this = :a - :a + :c / :c == :b / :b

p this
p this.simplify
