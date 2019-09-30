# Sample Dynamic Programming (DP) problem
#
# In this problem, we're on a crazy jumping ball, trying to stop, while
# avoiding spikes along the way.
#
# 1) You're given a flat runway with a bunch of spikes in it. The runway is
# represented by a boolean array which indicates if a particular (discrete)
# spot is clear of spikes. It is True for clear and False for not clear.
#
# Example array representation:
#
# __/\______/\____/\____
# T F T T T F T T F T T
#
# 2) You're given a starting speed S. S is a non-negative integer at any given
# point, and it indicates how much you will move forward with the next jump.
#
# 3) Every time you land on a spot, you can adjust your speed by up to 1 unit
# before the next jump.
#
# 4) You want to safely stop anywhere along the runway (does not need to be at
# the end of the array). You stop when your speed becomes 0. However, if you
# land on a spike at any point, your crazy bouncing ball bursts and it's game
# over.
#
# **The output of your function should be a boolean indicating whether we can
# safely stop anywhere along the runway.**

# Solve the Problem

# Recognize that this is a DP problem:
# It's main problem (Can we stop?) can be broken down into subproblems (Can we
# stop from any of the three next positions?)

# Identify problem variables:
# S: Speed
# P: Position

# Clearly express the recurrence relation:
# def can_we_stop?(S, P)
#   can_we_stop?(S, P+S) || can_we_stop?(S-1, P+S-1) || can_we_stop?(S+1, P+S+1)
# end

# Identify the base cases:
# Fail if:
# * P >= runway_array.length
# * runway_array[P] == false
# Pass if:
# * S == 0

# Iteratively or Recursively?
# Recursively for now.
# Add memoization

class BouncyBall
  def initialize(runway)
    @runway = runway
    @stops_from = {}
  end

  # This is the answer to the problem statement above.
  def stoppable?(initial_s)
    total_paths(initial_s) > 0
  end

  # Count the total number of stoppable paths.
  def total_paths(initial_s)
    reachable_stops(initial_s).count
  end

  # Get the indices of all the reachable stops.
  def reachable_stops(initial_s)
    k = [initial_s, 0]
    examine(*k)
    @stops_from[k]
  end

  private

  def examine(s, p)
    k = [s, p]
    res = @stops_from[k]
    return res if res

    if invalid?(s, p)
      @stops_from[k] = []
    elsif stopped?(s, p)
      @stops_from[k] = [p]
    else
      r1 = examine(s-1, p+s-1)
      r2 = examine(s, p+s)
      r3 = examine(s+1, p+s+1)

      @stops_from[k] = (r1 + r2 + r3).uniq
    end
  end

  def invalid?(s, p)
    p >= @runway.length || @runway[p] == false
  end

  def stopped?(s, p)
    s == 0
  end
end

def scientific(n)
  "%.3e" % n
end

START_TIME = Time.now

# Adjust these for experiment
L = 25
PROB = 0.2
PRE_ITERS = 1000000
runways = PRE_ITERS.times.map do
  a = [true] * (L * (1 - PROB)).round + [false] * (L * PROB).round
  a.shuffle!
end.uniq

ITERS = runways.count

# Set automatically
MAX_IS = (0.5 + (0.25 + 2*L)**0.5).floor

# Adjust for loading bar length
NUM_STEPS = 70

# Other loading bar stuff
C = '|'
I = " #{C} "
STEP_SIZE = (ITERS.to_f / NUM_STEPS).ceil
REAL_NUM_STEPS = ITERS / STEP_SIZE

puts "L: #{L}, PROB: #{PROB}, ITERS: #{ITERS}, MAX_IS: #{MAX_IS}\n\n"

results = Hash.new do |h, k|
  h[k] = {
    stoppable: [],
    total_paths: [],
    stops: [],
    total_time: [],
  }
end

ITERS.times.each do |iter|
  print "\r|" + ('=' * (iter / STEP_SIZE)) + (' ' * (REAL_NUM_STEPS - (iter / STEP_SIZE))) + '|' if iter % STEP_SIZE == 0
  # runway = L.times.map { rand >= PROB }
  runway = runways[iter]
  bb = BouncyBall.new(runway)

  (1..MAX_IS).to_a.shuffle.each do |is|
    a = Time.now
    stoppable = bb.stoppable?(is)
    total_paths = bb.total_paths(is)
    stops = bb.reachable_stops(is)
    total_time = Time.now - a

    results[is][:stoppable] << stoppable
    results[is][:total_paths] << total_paths if stoppable
    results[is][:stops] << stops.count if stoppable
    results[is][:total_time] << total_time
  end
end
print "\r" + ' ' * NUM_STEPS + "\r"

headers = [
  [(t = 'IS'), [MAX_IS.to_s.length, t.length].max],
  [(t = 'Stoppable Ratio'), [7, t.length].max],
  [(t = 'Avg Total Paths'), [11, t.length].max],
  [(t = 'Avg Reachable Stops'), [18, t.length].max],
  [(t = 'Avg Time'), [9, t.length].max],
  [(t = 'Total Time'), [7, t.length].max],
]

notes = [
  '',
  '',
  '(When Stoppable)',
  '(When Stoppable)',
  '',
  '',
]

headers.each_with_index do |(_, s), i|
  headers[i][1] = [s, notes[i].length].max
end

puts headers.inject(I.dup) { |h, (k, v)| h + k.center(v) + I }
puts notes.each_with_index.inject(I.dup) { |h, (n, i)| h + n.center(headers[i][1]) + I }
puts headers.inject(I[0..I.index(C)]) { |h, (k, v)| h + ''.center(v + I.length - C.length, '#') + C }

results.each do |is, data|
  s = I.dup
  s << is.to_s.rjust(headers[0].last) + I

  stoppable_ratio = data[:stoppable].count(&:itself).to_f / data[:stoppable].count
  s << stoppable_ratio.round(5).to_s.rjust(headers[1].last) + I

  avg_total_paths = data[:total_paths].sum.to_f / data[:total_paths].count
  s << scientific(avg_total_paths).to_s.rjust(headers[2].last) + I

  avg_stops = data[:stops].sum.to_f / data[:stops].count
  s << (avg_stops.round(5).to_s + " (#{data[:stops].min} - #{data[:stops].max})").rjust(headers[3].last) + I

  avg_total_time = data[:total_time].sum.to_f / data[:total_time].count
  s << scientific(avg_total_time).to_s.rjust(headers[4].last) + I

  total_time = data[:total_time].sum
  s << total_time.round(5).to_s.rjust(headers[5].last) + I

  puts s
end

puts "Took #{Time.now - START_TIME}s"
