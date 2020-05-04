# Is there a number n such that the decimal expansion of sqrt(n) starts with
# the decimal digits of n in reversed order?

def test?(n)
  str = n.to_s
  regex = /#{n.to_s}/
  bigger = n * 10**(2 * str.length)
  sqrt = (bigger ** 0.5).to_i.to_s
  sqrt.match?(regex)
end

(1..).each { |n|
  puts "#{n} works" if test?(n)
  puts n if n % 1_000_000 == 0
}
