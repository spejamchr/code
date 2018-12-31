POPULATION_SIZE = 25
NUM_BITS = 8
NUM_GENERATIONS = 100
CROSSOVER_RATE = 0.7
MUTATION_RATE = 0.01

class Chromosome

  attr_accessor :genes

  def initialize(genes = "")
    if genes == ""
      self.genes = (1..NUM_BITS).map{ rand(2) }.join
    else
      self.genes = genes
    end
  end

  def to_s
    genes.to_s
  end

  def count
    genes.count
  end

  def fitness
    genes.count("1")# / (genes.count("0")+1)
    100/((eval("0b#{genes}") - 100).abs+0.001)
  end

  def mutate!(gen)
    mutated = ""
    0.upto(genes.length - 1).each do |i|
      allele = genes[i, 1]
      if rand <= (MUTATION_RATE)
        mutated += (allele == "0") ? "1" : "0"
      else
        mutated += allele
      end
    end

    self.genes = mutated
    self
  end

  def &(other)
    locus = rand(genes.length) + 1

    child1 = genes[0, locus] + other.genes[locus, other.genes.length]
    child2 = other.genes[0, locus] + genes[locus, other.genes.length]

    return [
      Chromosome.new(child1),
      Chromosome.new(child2),
    ]
  end
end

class Population

  attr_accessor :chromosomes

  def initialize
    self.chromosomes = Array.new
  end

  def inspect
    chromosomes.join(" ")
  end

  def seed!
    chromosomes = Array.new
    1.upto(POPULATION_SIZE).each do
      chromosomes << Chromosome.new
    end

    self.chromosomes = chromosomes
  end

  def count
    chromosomes.count
  end

  def fitness_values
    chromosomes.collect(&:fitness)
  end

  def total_fitness
    fitness_values.inject{|total, value| total + value }
  end

  def max_fitness
    fitness_values.max
  end

  def average_fitness
    total_fitness.to_f / chromosomes.length.to_f
  end
  
  def selecter
    rand_selection = rand(total_fitness)

    total = 0
    chromosomes.each do |chromosome|
      return chromosome if (total+=chromosome.fitness) >= rand_selection
    end
  end
  
  def max_chro
    hash={}
    chromosomes.each do |chrom|
      hash[chrom.fitness]=chrom
    end
    hash[max_fitness]
  end

  def select
    if total_fitness < 1
      max_chro
    else
      rand_selection = rand(total_fitness)

      total = 0
      chromosomes.each_with_index do |chromosome, index|
        total += chromosome.fitness
        return chromosome if total > rand_selection || index == chromosomes.count - 1
      end
    end
  end
end

population = Population.new
population.seed!

start=Time.new
1.upto(NUM_GENERATIONS).each do |generation|

  offspring = Population.new

  while offspring.count < population.count
    parent1 = population.select
    parent2 = population.select

    if rand <= CROSSOVER_RATE
      child1, child2 = parent1 & parent2
    else
      child1 = parent1
      child2 = parent2
    end

    child1.mutate!(generation)
    child2.mutate!(generation)

    if POPULATION_SIZE.even?
      offspring.chromosomes << child1 << child2
    else
      offspring.chromosomes << [child1, child2].sample
    end
  end

  puts "Generation #{generation} - Average: #{population.average_fitness.round(0)} - Max: #{population.max_fitness} - Total: #{population.total_fitness}"

  population = offspring
end
puts
puts "Took #{Time.new-start} sec"

puts "Final population:"
puts population.inspect
