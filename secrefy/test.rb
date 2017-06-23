class Test
  DEFAULT_BITS = 8.freeze
  LEAST = (2**10).freeze
  MOST = (2**11).freeze

  ################################################################################
  # Generate an Array of Strings from a range of integers
  #
  #  # Example Usage:
  #  array_of_words = Test.words
  #
  #  # You can also specify a range of values with which to create words
  #  array_of_words = Test.words(least: 0, most: 100)
  #
  def self.words(params = {})
    least  = params[:least]  || LEAST
    most   = params[:most]   || MOST
    words = (least..most).to_a.map{ |word|
      word.to_s(2).scan(/.{1,8}/).map{|letter| letter.to_i(2).chr}.join
    }
  end
end

################################################################################
# Test a Hash Function for Bias
#
#  # Example Usage:
#  a = BiasTest.new
#  a.show
#
#  # You can also specify your own words to hash, and your own hasing algorithm
#  a = BiasTest.new(words: array_of_strings, hasher: :hasht)
#  a.show
#
# Initialization params are optional. Will default to using the #hasht hasher
# and the default Test#words settings.
#
class BiasTest < Test
  attr_reader :total_time, :hasher, :words

  def initialize(params = {})
    @hasher = params[:hasher] || :hasht
    @words  = params[:words] || Test.words
  end

  def hashes
    return @hashes if @hashes
    start = Time.now
    hashes = words.map(&hasher)
    endd = Time.now
    @total_time = endd - start
    @hashes = hashes
  end

  def percents
    return @percents if @percents
    @percents = (0...(words.size-1)).to_a.map{ |n| hashes[n].diff(hashes[n+1], 2) }
  end

  def histogram
    small = percents.min
    big = percents.max
    dif = big - small
    groups = 10
    width = (dif/groups.to_f).ceil
    places = (0..groups).map{|g| percents.map{|n| n >= (small + g*width) && n < (small + ((g+1)*width)) }.count(true) }
    top = places.max/(places.max/10.0)
    bottom = 1
    arr = (bottom..top).to_a.reverse.map do |n|
      places.map{|p| p >= n*(places.max/10.0) ? "\u2588 " : '  ' }
    end
    puts "\nHistogram (should be a normal curve):\n"
    arr.each{|n| puts n.join}
    puts
    puts "places: #{places}"
  end

  def show
    average_percent = percents.inject(:+)/(words.count).to_f
    average_time = total_time / (words.count)

    puts "\nBias Test"
    puts "words count: #{words.count}"
    puts "average time:    #{average_time}"
    puts "average percent: #{average_percent}"
    puts "minimum percent: #{percents.min}"
    puts "maximum percent: #{percents.max}"

    histogram
  end
end

################################################################################
# Test a random stream. By converting the random stream to a random series of
# coordinates on a grid, the value of PI can be calculated. The accuracy of this
# calculated PI depends on the size of the grid, the size of the stream, and the
# quality of the random number stream
#
#  # Example usage:
#  PiTest.new(stream: random_stream, bits: 10).show
#
#  # Or:
#  PiTest.new(stream: random_stream).show
#
# The stream parameter is not optional. The bits parameter is optional.
#
class PiTest < Test
  attr_reader :stream, :radius, :xy_center, :bits

  def initialize(params = {})
    @stream = params[:stream]
    @bits = params[:bits] || DEFAULT_BITS
    @radius = @xy_center = (2**(@bits - 1))
  end

  def show_perfect
    types = (0...radius*2).map{|n| "%0.#{bits}d" % n.to_s(2)}
    perfect_stream = types.map{|f| types.map{|s| [f,s]}}.flatten.join
    perfect_test = PiTest.new(stream: perfect_stream, bits: bits)
    puts "\nPerfect PI Test"
    puts "stream length: #{perfect_test.stream.length}"
    puts "true count:    #{perfect_test.trues.count}"
    puts "calculated pi: #{perfect_test.pi_value}"
  end

  def trues
    # return @trues if @trues
    @trues = (0...groups.count/2).map do |n|
      x = groups[n*2].to_i(2)
      y = groups[n*2+1].to_i(2)
      r = ( (x - xy_center)**2 + (y - xy_center)**2 )**(0.5)
      r <= radius
    end
  end

  def groups
    @groups ||= stream.scan(/.{1,#{bits}}/)
  end

  def ttrues
    # return @trues if @trues
    @trues = (0...(stream.length/(2*bits))).map do
      x = stream.slice!(0...bits).to_i(2)
      y = stream.slice!(0...bits).to_i(2)
      r = ( (x - xy_center)**2 + (y - xy_center)**2 )**(0.5)
      r <= radius
    end
  end

  def pi_value
    @pi_value ||= trues.count(true)/(trues.count.to_f)*4
  end

  def show
    puts "\nPI Test"
    puts "stream length: #{stream.length}"
    puts "true count:    #{trues.count}"
    puts "calculated pi: #{pi_value}"
    show_perfect
  end
end

################################################################################
# Test a random stream. By converting the random stream to a random series of
# n-tuples, we can verify that each type of n-tuple has approximately the same
# frequency.
#
#  # Example usage:
#  GroupsTest.new(stream: random_stream, bits: 10).show
#
#  # Or:
#  GroupsTest.new(stream: random_stream).show
#
# The stream parameter is not optional. The bits parameter is optional.
#
class GroupsTest < Test
  attr_reader :stream, :bits, :types

  def initialize(params = {})
    @stream = params[:stream]
    @bits = params[:bits] || DEFAULT_BITS
    @types = (0...2**bits).map{|n| "%0.#{bits}d" % n.to_s(2)}
  end

  def nums
    return @nums if @nums
    groups = stream.scan(/.{1,#{bits}}/)
    @nums = types.map{|t| groups.count(t) }
  end

  def histt
    maxi = nums.max
    mini = nums.min
    arr = (1..10).to_a.map do |n|
      nums.map{|l| l >= maxi - n*(maxi-mini)/10 ? "\u2588" : ' '}
    end
    puts "Histogram (from min to max):\n"
    arr.each{|n| puts n.join}
    puts "Max: #{maxi}, Min: #{mini}"
  end

  def histogram
    max = nums.max
    min = nums.min
    top = max/(max/10)
    arr = (1..top).to_a.reverse.map do |n|
      nums.map{|p| p >= n*(max/10) ? "\u2588" : ' ' }
    end
    puts "Histogram (all should be about equal):\n"
    arr.each{|n| puts n.join}
    puts "counts: #{nums}"
  end

  def show
    puts "\nGroups Test"
    histogram
    puts "zoomed:"
    histt
  end
end

################################################################################
# Test a random stream. By counting runs of ones and runs of zeros, and
# comparing how many such runs should appear in an ideally random sequence, we
# can give the stream a Z-score indicating how many standard deviations you are
# from the ideally random source. But even ideally random sources should deviate
# so treat the results with care.
#
#  # Example usage:
#  RunsTest.new(stream: random_stream).show
#
# The stream parameter is not optional.
#
class RunsTest < Test
  attr_reader :stream

  def initialize(params = {})
    @stream = params[:stream]
  end

  def show
    puts "\nRuns test (standard deviations from expected number of runs)"
    puts "stream z score: #{stream.z}"
  end
end


# Multiply 2**31 by random floats on (0,1) until you reach 1. Repeat this
# 100,000 times. The number of floats needed to reach 1 should follow a certain
# distribution.
#
class SqueezeTest < Test
  attr_reader :stream, :bits, :times

  def initialize(params = {})
    @stream = params[:stream]
    @bits = params[:bits] || DEFAULT_BITS
  end

  def groups
    @groups ||= stream.scan(/.{1,#{bits}}/)
  end

  def floats
    @floats ||= groups.map{ |g| ('0.' + g.to_i(2).to_s).to_f }
  end

  def histogram
    small = times.min
    big = times.max
    dif = big - small
    groups = 10
    width = (dif/groups.to_f).ceil
    places = (0..groups).map{|g| times.map{|n| n >= (small + g*width) && n < (small + ((g+1)*width)) }.count(true) }
    top = (places.max/(places.max/10.0)).to_i
    bottom = 1
    arr = (bottom..top).to_a.reverse.map do |n|
      places.map{|p| p >= n*(places.max/10.0) ? "\u2588 " : '  ' }
    end
    puts "Histogram (should be a normal curve):\n"
    arr.each{|n| puts n.join}
    puts
    puts "places: #{places}"
  end

  def show
    index = rand(floats.count)
    @times = (0...100000).map do
      count = 0
      num = 2**35
      while num != 1
        num = (num * floats[index % floats.count]).ceil
        count += 1
        index += 1
      end
      count
    end
    puts "\nSqueeze Test"
    histogram
  end
end
