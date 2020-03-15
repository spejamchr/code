# In a regular Fibonacci sequence the first two terms are given, and subsequent
# terms are defined as the sum of the previous two.
#
#   F_0 = a, F_1 = b, F_(n+1) = F_n + F_(n-1)
#
# In a Random Fibonacci sequence the first two terms are given, and subsequent
# terms are defined as either the sum or the difference (chosen randomly) of
# the previous two.
#
#   R_0 = a, F_1 = b, F_(n+1) = F_n +- F_(n-1)
#
# For F, as `n` approaches infinity, the ratio between consecutive
# terms--`F_n/F_(n-1)`--approaches the golden ratio.
#
# For R, as `n` approaches infinity, does the ratio between consecutive terms
# approach some constant value as well?

require './graphit.rb'

class RFib
  # a - first term of the sequence
  # b - second term of the sequence
  # p - probability of choosing to sum the numbers (otherwise the difference)
  def initialize(a, b, p)
    type 'a', a, Integer
    type 'b', b, Integer
    type 'p', p, Numeric
    raise "a and b cannot both be 0" if a == 0 && b == 0
    raise "Expected p to be in (0..1), but found #{p}" unless (0..1) === p

    @a = a
    @b = b
    @p = p.to_f

    @min = 0
    @sequence = [a, b]
  end

  def at(n)
    type 'n', n, Numeric
    raise "n may not be less than 0, but was #{n}" if n < 0
    reset if n < @min

    n = n.floor

    if n == n.to_i || true
      @sequence[n.to_i] ||= calc_at(n.to_i)
    else
      (at(n.ceil) - at(n.floor)) / (n.ceil - n.floor) * (n - n.floor) + at(n.floor)
    end
  end

  def ratio(n)
    type 'n', n, Numeric
    raise "n may not be less than 1, but was #{n}" if n < 1
    n = n.floor

    Math.exp((1 / n.to_r) * Math.log(at(n).abs))
  end

  def reset
    return if @p >= 1 || @p <= 0

    @min = 0
    @sequence = [@a, @b]
  end

  private

  def type(name, thing, klass)
    return if thing.is_a? klass

    raise "Expected #{name} to be a #{klass} but got a #{thing.class}: #{thing}"
  end

  def calc_at(n)
    next_seq while (@min < n)
    @sequence.first
  end

  def next_seq
    @min += 1
    b = rand < @p ?
      @sequence.last + @sequence.first :
      @sequence.last - @sequence.first

    @sequence = [@sequence.last, b]
  end
end

r = RFib.new(1,1,0.5)
graph = Graphit.new(300_000, 400_000, [r.method(:ratio)])
puts graph.bounds
puts graph.to_s
