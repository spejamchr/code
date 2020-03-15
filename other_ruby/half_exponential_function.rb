# frozen_string_literal: true

require './graphit.rb'

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

fns = %i[f x2 s exp sl].map { |f| method(f) }
graph = Graphit.new(m * 0.015, m * 0.02, fns)
# graph = Graphit.new(m * 0.015, m * 0.03, [method(sl)])
puts graph.bounds
puts graph.to_s
