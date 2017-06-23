class Code

  OPERATORS=['+','-','*','/']
  VALUES=['s','v','a','t','1','2']
  MUTATE_FACTOR=0.9
  S_VAL=nil
  V_VAL=nil
  A_VAL=nil
  T_VAL=nil
  def initialize(length=20,code=nil,fitness=nil)
    @code = code
    unless code
      @code = []
      length.times do
        @code << VALUES.sample
        @code << OPERATORS.sample
      end
      @code << VALUES.sample
    end
    @fitness = fitness || self.set_fitness
  end

  def code
    @code
  end

  def params
    [ s = S_VAL || rand*10,
      v = V_VAL || rand*10,
      a = A_VAL || rand*10,
      t = T_VAL || rand*10,
    ]
  end

  def to_s
    @code.join
  end

  def calc(s,v,a,t)
    eval(self.to_s)
  end

  def set_fitness
    Random.new(115032730400174366788466674494640623225)
    results=[]
    1000.times do
      s = S_VAL || rand*10
      v = V_VAL || rand*10
      a = A_VAL || rand*10
      t = T_VAL || rand*10
      code = Code.new(1,'s+v*t+t*t*a/2'.split(''),0)
      real=code.calc(s,v,a,t)
      tested=self.calc(s,v,a,t)
      results<<(((real-tested)**2)**(0.5))
    end
    fitness = results.inject(&:+)/results.count
    if fitness.nan?
      return 10**50*rand(1000)
    elsif fitness == Float::INFINITY
      return 10**50*rand(1000)
    else
      return fitness
    end
  end

  def fitness
    @fitness
  end

  def reproduce(other)
    a_code = self.mutate.code.join.split(//)
    b_code = other.mutate.code.join.split(//)
    cut_off = rand(a_code.size)
    group_a1 = a_code.shift(cut_off)
    group_b1 = b_code.shift(cut_off)
    group_a2 = a_code
    group_b2 = b_code
    one = Code.new(nil,group_a1+group_b2)
    two = Code.new(nil,group_b1+group_a2)
    thr = Code.new(nil,group_a1+group_a2)
    fou = Code.new(nil,group_b1+group_b2)
    array = {one.fitness => one.mutate,
             two.fitness => two.mutate,
             thr.fitness => thr.mutate,
             fou.fitness => fou.mutate,
            }
    winners = [array[array.keys.sort[0]], array[array.keys.sort[1]]]
    [winners[0].mix, winners[1].mix]
  end

  def mix
    code = self.code.join
    code = code.split('+').shuffle.join('+')
    code = code.split('-').shuffle.join('-')
    Code.new(nil,code.split(//))
  end

  def mutate
    (rand < MUTATE_FACTOR ? 0 : 0)*rand.to_i.times do
      code ||= self.code
      number = rand(code.length)
      if OPERATORS.include?(code[number])
        code[number] = OPERATORS.sample
      else
        code[number] = VALUES.sample
      end
    end
    Code.new(nil,code)
  end
end

class Population
  def initialize(number=nil,array=nil,seed=nil)
    number ||= 10
    @codes={}
    if array
      array.each do |code|
        @codes[code.fitness]=code
      end
    else
      number.times do
        new_code=Code.new
        @codes[new_code.fitness]=new_code
      end
    end
    if seed
      code = Code.new(nil,seed.split(''))
      @codes[code.fitness] = code
    end
  end

  def codes
    @codes
  end

  def most_fit
    fit = self.codes.map{|fi,co| co.fitness}.min
    self.codes[fit]
  end

  def next_gen
    codes_array = []
    self.codes.keys.each do |key|
      codes_array << self.codes[key]
    end
    codes_array = codes_array.shuffle
    gen_2 = []
    (0..(codes_array.size/2-1)).each do |i|
      gen_2 << codes_array[i*2+1].reproduce(codes_array[i*2])
    end
    Population.new(nil,gen_2.flatten)
  end

  def display
    self.codes.each{|fi,co| print "#{co.to_s}, fitness: #{fi}\n"}
  end

  def average
    self.codes.keys.inject(&:+)/(self.codes.count)
  end
end

###############################
###### Begin the Program ######
###############################
start = Time.new
###############################
###############################
###############################


this = Population.new#(nil,nil,'1+t*t/2*a+t/s-1+t+2*a-s+1*s*t+2-2-t*1+t*1')

 this.display
puts

100.times do
  this = this.next_gen
  print this.average.to_s + '   '
  puts [this.most_fit.code.join, this.most_fit.fitness].join('    ')
  this.display
  puts
end

###############################
stop = Time.new
###############################
puts "This took #{stop-start} seconds."

# this.display
best = this.most_fit
puts "Best:\n"
puts best
puts best.fitness


tests = ['s+v*t+t*t*a/2', # The equation they teach in Physics
         '1+t*t/2*a+t/s-1+t+2*a-s+1*s*t+2-2-t*1+t*1',
         '1+t*t/2*a-a/s-1+t+t*a+t+v-v-1+2+v*t*1/2*2',
         '2*t*2-2+t*1*v+a-v+2-t+s/1+s-s*1+t/2*a/t+2',
         '1+t*a*2-2/t-s-2-t/v/t-2+t+s*2+2+t*t+2+t*a',
         'v*t/2*s*2+t-s*a+a+a*2+v/t+v*s/s+t*2*a+2/s',
         best.code.join,
       ]

params = best.params

p params

tests.each do |text|
  puts "\nTesting:"
  code = Code.new(nil,text.split(''))
  puts "#{code.to_s}        #{code.fitness}    #{code.calc(*params)}"
end
