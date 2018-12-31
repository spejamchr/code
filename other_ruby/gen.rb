def random_chromosome
  Array.new(32).map {|e| rand 2 }
end

def calc_fitness(chromosome)
  chromosome.map {|e| e if e == 1}.compact.size
end

def mate(chromo1, chromo2)
  mutate(chromo1.first(16) + chromo2.last(16))
end

def mutate(chromo)
  1.times {chromo[rand 32] = rand 2}
  chromo
end

def alphas(arrs)
  tmp = []
  arrs.each_index {|i| tmp << [calc_fitness(arrs[i]),i]}
  tmp.sort!.reverse.map{|e| arrs[e[1]]}.first 10
end

def print_alpha_stats(alphas)
  scores = alphas.map{|alpha| calc_fitness(alpha) }
  average = (scores.inject(:+)) / (scores.count)
  max = scores.sort.last
  puts "Average: #{average}, Max: #{max}"
end

class Array
  def random
    self[rand self.size]
  end
  
  def is_spartan?
    self == (Array.new(32).fill 1)
  end
end
 
start = Time.now
NUM_OFFSPRING = 10
SPARTAN = Array.new(32).fill 1
SEEDS = Array.new(NUM_OFFSPRING).collect {random_chromosome}
top10 = alphas(SEEDS)
 
i = 0
loop do
  case top10.include? SPARTAN
  when true
    winners = top10.collect {|a| a if a.is_spartan?}.compact
    puts "#{winners.size} member(s) reached spartan status!"
    puts "completed in #{Time.now - start} seconds"
    break
  else
    puts "*** ALPHAS FROM GENERATION: #{i} ***"
    offspring = []
    NUM_OFFSPRING.times do |j|
      offspring << mate(top10.random, top10.random)
    end
    top10 = alphas(offspring)
    print_alpha_stats(top10)
    i += 1
  end
  break if i >= 1000
end
puts top10.to_s