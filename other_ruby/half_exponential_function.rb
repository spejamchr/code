# frozen_string_literal: true

# A = 0.87416060015039571
A = 0.7

def op(x)
  x**2
end

def invop(x)
  x**0.5
end

def g(x)
  raise "Must be within [0..#{A}, got #{x}" unless (0..A).include? x

  t = op(x)
  max = op(A)

  (t / max) * (1 - A) + A

  # (x / A) * (1 - A) + A
end

def ginv(x)
  raise "Must be within [#{A}..1], got #{x}" unless (A..1).include? x

  max = op(A)

  invop((x - A) * max / (1 - A))

  # (x - A) * A / (1 - A)
end

def f(x)
  if x < 0
    Math.log(f(Math.exp(x)))
  elsif x <= A
    g(x)
  elsif x <= 1
    Math.exp(ginv(x))
  else
    Math.exp(f(Math.log(x)))
  end
end

# (0..10).each { |n| puts ginv(g(n * A / 10)) }

def format_n(n, leading, trailing)
  n.floor.to_s.rjust(leading) +
    '.' +
    ((n - n.floor) * 10**trailing).floor.to_s.ljust(trailing, '0')
end

(0..50).each do |n|
  x = n
  fx = f(x)
  puts "f(#{x}) = #{format_n(fx, 2, 3)} --- exp(#{x}) = #{format_n(Math.exp(x), 3, 3)} --- f(f(#{x})) = #{format_n(f(f(x)), 3, 3)} --- x**2 = #{format_n(x**2, 3, 3)}"
end

a = 0
b = 2e12
m = (a + b) / 2.0
500.times do
  m = (a + b) / 2.0
  if f(m) > m**2
    b = m
  else
    a = m
  end
end

puts "m: #{m}"
puts "f(#{m}) = #{f(m)} --- #{m}**2 = #{m**2}"

class Graphit
  require 'io/console'
  def initialize(obj, xa, xb, graphs)
    @obj = obj
    @graphs = graphs

    # Columns
    @xa = xa
    @xb = xb

    @rows, @cols = IO.console.winsize.map { |n| n - 5 }
    @display = @rows.times.map { @cols.times.map { +' ' } }

    @values = graphs.map { |g| values_for(g) }

    # Rows
    @ya = @values.flatten.min
    @yb = @values.flatten.max
  end

  def bounds
    {
      xa: @xa,
      xb: @xb,
      ya: @ya,
      yb: @yb
    }
  end

  def to_s
    @values.zip('A'..).each do |g, l|
      g.each_with_index do |y, j|
        @display.fetch(y_to_i(y)).fetch(j)[0] = l
      end
    end

    [
     '#' * (@cols + 2),
     @display.reverse.map { |r| '#' + r.join + '#' }.join("\n"),
     '#' * (@cols + 2),
    ].join("\n")
  end

  private

  def x_to_j(x)
    raise "Out of bounds: (#{@xa}..#{@xb}), but was #{x}" unless (@xa..@xb).include? x

    (((x - @xa) / (@xb - @xa)) * (@cols - 1)).round
  end

  def y_to_i(y)
    raise "Out of bounds: (#{@ya}..#{@yb}), but was #{y}" unless (@ya..@yb).include? y

    (((y - @ya) / (@yb - @ya)) * (@rows - 1)).round
  end

  def j_to_x(j)
    raise "Out of bounds: (0...#{@cols}), but was #{j}" unless (0...@cols).include? j

    (j / @cols.to_f) * (@xb - @xa) + @xa
  end

  def i_to_y(i)
    raise "Out of bounds: (0...#{@rows}), but was #{i}" unless (0...@rows).include? i

    (i / @rows.to_f) * (@yb - @ya) + @ya
  end

  def values_for(g)
    @cols.times.map do |j|
      x = j_to_x(j)
      @obj.send(g, x)
    end
  end
end

def exp(x)
  Math.exp(x) / 10_000.0
end

def x2(x)
  x**2
end

def ff(x)
  f(f(x))
end

def s(x)
  @s ||= {}
  n = x.floor
  @s[n] ||= n < 2 ? 1 : s(x - 2) + s(x - 1)
end

def sl(x)
  a = s(x.floor)
  b = s(x.ceil)

  (x - x.floor) * (b - a) + a
end

graph = Graphit.new(self, m * 0.015, m * 0.02, %i[f x2 s exp sl])
# graph = Graphit.new(self, m * 0.015, m * 0.03, %i[sl])
puts graph.bounds
puts graph.to_s
