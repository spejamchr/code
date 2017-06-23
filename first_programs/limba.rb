require "benchmark"

def l(function)
  -> (a, *b) {
    if a.respond_to?(function)
      a.send(function, *b)
    else
      self.send(function, a, *b)
    end
  }
end

both = -> (a, b) { a && b }
iff = -> (a, b, c) { a ? b : c }

# Limba Factorial
#
h = {}
q = -> (n) {
  iff.(
    l(:==).(n, 0),
    -> { 1 },
    -> {
      iff.(
        l(:!).(l(:nil?).(l(:[]).(h, n))),
        -> { l(:[]).(h, n) },
        -> { l(:*).(n, q.(l(:-).(n, 1))) }
      ).()
    }
  ).()
}

f = -> (n) {
  iff.(
    l(:==).(n, 0),
    -> { 1 },
    -> {
      iff.(
        l(:!).(l(:nil?).(l(:[]).(h, n))),
        -> { l(:[]).(h, n) },
        -> {
          iff.(
            both.(l(:>).(n, 1000), l(:nil?).(l(:[]).(h, l(:-).(n, 1000)))),
            -> { l(:[]=).(h, l(:-).(n, 1000), f.(l(:-).(n, 1000))) },
            -> {}
          ).()
          l(:[]=).(h, n, l(:*).(n, q.(l(:-).(n, 1))))
        }
      ).()
    }
  ).()
}

# Proc Factorial
#
fact_hash = {}
factorial = -> (n) {
  return 1 if n == 0
  return fact_hash[n] unless fact_hash[n].nil?
  if n > 4000 && fact_hash[n-4000].nil?
    fact_hash[n-4000] = factorial.(n-4000)
  end
  fact_hash[n] = n * factorial.(n-1)
}

# Class Factorial
# Optimized for finding a big factorial quickly
#
class Factorial
  @fact_hash = {}
  DEPTH_LIMIT = 5000

  def self.[] n
    factorials n
  end

  def self.reset_fact_hash; @fact_hash = {}; end

  private

  def self.factorials n
    return 1 if n == 0
    return @fact_hash[n] unless @fact_hash[n].nil?
    if n > DEPTH_LIMIT && @fact_hash[n-DEPTH_LIMIT].nil? && n-DEPTH_LIMIT > (@fact_hash.keys.last || 0)
      @fact_hash[n-DEPTH_LIMIT] = factorials(n-DEPTH_LIMIT)
    end
    n * factorial_non_save(n-1)
  end

  def self.factorial_non_save n
    return 1 if n == 0
    return @fact_hash[n] unless @fact_hash[n].nil?
    n * factorial_non_save(n-1)
  end
end

$fact_hash = {}
def factorial n
  return 1 if n == 0
  return $fact_hash[n] unless $fact_hash[n].nil?
  if n > 5000 && $fact_hash[n-5000].nil?
    $fact_hash[n-5000] = factorial(n-5000)
  end
  $fact_hash[n] = n * factorial(n-1)
end

clear_hashes = -> {
  $fact_hash = {}
  fact_hash = {}
  h = {}
  Factorial.reset_fact_hash
  puts "\n\nCleared all Hashes"
}

ns = [30_000]
puts "\n\n---Find factorial of #{ns.join(', ')}---"
Benchmark.bm(12) do |x|
  x.report("class:")  { ns.each{|num| Factorial[num]  }}
  x.report("method:") { ns.each{|num| factorial(num)  }}
  x.report("limba:")  { ns.each{|num| f.(num)         }}
  x.report("proc:")   { ns.each{|num| factorial.(num) }}

end

clear_hashes.()

n = 40_000
puts "\n\n---Find first #{n} factorials---"
Benchmark.bmbm(12) do |x|
  x.report("class:")  { (1..n).each{|num| Factorial[num]  }}
  x.report("method:") { (1..n).each{|num| factorial(num)  }}
  x.report("limba:")  { (1..n).each{|num| f.(num)         }}
  x.report("proc:")   { (1..n).each{|num| factorial.(num) }}

end

nth = 20_000
count = 100_000
puts "\n\n---Look up factorial of #{nth} #{count} times---"
Benchmark.bm(12) do |x|
  x.report("class:")  { count.times{ Factorial[nth]  }}
  x.report("method:") { count.times{ factorial(nth)  }}
  x.report("limba:")  { count.times{ f.(nth)         }}
  x.report("proc:")   { count.times{ factorial.(nth) }}

end

puts [0, 1, 100, 1_879, 9_000, 20_000, 32_439]
  .map{|num| factorial(num) == Factorial[num] &&
             Factorial[num] == factorial.(num) &&
             factorial(num) == f.(num)}.all?

def time method
  start = Time.new
  send(method)
  puts "Took #{Time.new - start} sec"
end
