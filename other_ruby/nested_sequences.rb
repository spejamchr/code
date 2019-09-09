# I want to find a way to nest sequences without interference
#
# Take any sequence of positive integers, like this one: 2, 4, 8, 16, 32, ...
# Let's call it the "parent sequence".
#
# Then interpret the values of the parent sequence as the difference in indices
# between members in some "sub-sequence":
#
#   .  1  2. 1  2  3  4. 1  2  3  4  5  6  7  8.
#   1, _, 1, _, _, _, 1, _, _, _, _, _, _, _, 1, ...
#
# To "nest" the parent sequence, begin by creating a similar sub-sequence:
#
#   2, _, 2, _, _, _, 2, _, _, _, _, _, _, _, 2, ...
#
# And interleave the two sub-sequences so the first member of the second
# sub-sequence falls into the first gap in the first sub-sequence.
#
#   1, _, 1, _, _, _, 1, _, _, _, _, _, _, _, 1, ...
#      2, _, 2, _, _, _, 2, _, _, _, _, _, _, _, 2, ...
#
#   1, 2, 1, 2, _, _, 1, 2, _, _, _, _, _, _, 1, 2, ...
#
# In this example we can nest the first two sub-sequences. Can we add a third?
#
#   1, 2, 1, 2, _, _, 1, 2, _, _, _, _, _, _, 1, 2, ...
#               3, _, 3, _, _, _, 3, _, _, _, _, _, _, _, 3, ...
#                     X
#
# Nope. We can't build a nested sequence by shifting identical sub-sequences
# built from this parent sequence. We want the sub-sequences to fit together
# perfectly like Russian nesting dolls.
#
# A simple group of solutions is any constant parent sequence, such as: 2, 2,
# 2, 2, ...  This example will create a cyclical nested sequence with two
# sub-sequences:
#
#   1, 2, 1, 2, 1, 2, 1, 2, ...
#
# Sure, this works, but we're after a non-constant parent sequence, so that the
# resulting nested sequence contains an infinite number of sub-sequences.

# Attempt to nest a parent sequence, and give information about the attempt
#
# This class creates a nested sequence out of "groups". In a perfectly nested sequence
# each group would have exactly one item. However, in poorly-nesting sequences
# sub-sequences will overlap. We put these items in the same "group".
#
class Nester
  # @param parent_sequence
  #   Any object that responds to #each with an infinite iteration of integers
  def initialize(parent_sequence)
    @parent_sequence = parent_sequence
  end

  # @param num_groups
  #   The number of groups to populate in the infinite nested sequence
  def info(num_groups)
    groups = populate_groups(num_groups)
    flat = groups.flatten
    # i = groups.count == flat.count ? flat : groups
    # puts i.inspect
    items = flat.count
    avg = items / groups.count.to_f
    puts "#{items} items (#{avg} items per group)"
    puts "sub-sequences: #{flat.max}"
  end

  private

  attr_reader :parent_sequence

  def populate_groups(num_groups)
    # First, cache the parent_sequence, so we only have to calculate it once.
    cached = [0]
    parent_sequence.each do |n|
      group_index = cached.last + n
      break if group_index >= num_groups

      cached << group_index
    end

    # Second, initialize all the groups
    groups = num_groups.times.map { [] }

    # Then, populate all the groups, until none are empty.
    (1..).each do |n|
      beginning = groups.find_index(&:empty?)
      break if beginning.nil?

      cached.each do |i|
        break if groups[beginning + i].nil?

        groups[beginning + i] << n
      end
    end

    groups
  end
end

def fib(n)
  return 1 if n <= 1

  @fib ||= []
  @fib[n] ||= fib(n - 2) + fib(n - 1)
end

def trib(n)
  return 1 if n <= 2

  @trib ||= []
  @trib[n] ||= trib(n-3) + trib(n - 2) + trib(n - 1)
end

def nester(base)
  cache = { 0 => base }

  based_nester = lambda do |n|
    exp = 1
    exp += 1 while (n % base**exp).zero? && (base**exp > base**(exp - 1))
    exp -= 1

    return cache[exp] if cache[exp]

    if n == base**exp
      cache[exp] ||= ((1...n).map(&based_nester).sum + 1) * base
    else
      raise 'crap'
    end
  end
end

PARENT_SEQUENCES = {
  # integers: (1..),
  # fib: (2..).lazy.map { |n| fib(n) },
  # trib: (3..).lazy.map { |n| trib(n) },
  # double: (1..).lazy.map { |n| 2**n },
  # triple: (1..).lazy.map { |n| 3**n },
  # quad: (1..).lazy.map { |n| 4**n },
  # quint: (1..).lazy.map { |n| 5**n },
  # cycle: [2].lazy.cycle, # Boring, but works
  nester1: (1..).lazy.map(&nester(1)), # Works!
  nester2: (1..).lazy.map(&nester(2)), # Works!
  nester3: (1..).lazy.map(&nester(3)), # Works!
  nester4: (1..).lazy.map(&nester(4)), # Works!
}.freeze

PARENT_SEQUENCES.each do |k, s|
  puts "#{k.to_s.rjust(15)}: #{s.first(20)}"
end

def test(seq)
  puts
  puts seq
  Nester.new(PARENT_SEQUENCES.fetch(seq)).info(100000)
end

PARENT_SEQUENCES.keys.each { |seq| test(seq) }

# I strongly believe it's impossible to nest a monotonically increasing parent
# sequence, but I don't know how to prove it.
