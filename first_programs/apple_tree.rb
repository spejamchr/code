def profile block_description, &block
  profiling_on = false
  if profiling_on
    start_time = Time.new
    block[]
    duration = Time.new - start_time
    puts "#{block_description}: #{duration} seconds"
  else
    block[]
  end
end

class AppleTree
  
  profile "initialize definition" do
    def initialize
      @height = rand(5) + 10
      @age = 1
      @apples = 0
      @sickness = rand(0)
      puts "You just got an Apple Tree! It's 1 year old."
    end
  end
  
  profile "height" do
  def height
    puts "You measure the Apple Tree."
    puts "It is #{(@height/12).to_i}' #{(@height%12).to_i}'' tall"
    if @sickness >= 10
      puts 'This tree doesn\'t look so good...'
    elsif @sickness == 0
    elsif (@age / @sickness) >= 3
      puts "The leaves are wilting"
    end
  end
  end
  
  profile "count apples" do
  def count_apples
    puts "You count the apples."
    if @apples > 0
      puts "There are #{@apples.to_i} apples on the tree."
    else
      puts "There aren't any apples to count!"
    end
  end
  end
  
  profile "one year passes" do
  def one_year_passes
    @age = @age + 1
    if (@age + @sickness) >= 40
      puts "The Apple Tree grew old and died... It was nearly #{@age} years old..."
      exit
    end
    
    @height = @height + (@height / (@age ** (1.02 + 0.1 * @sickness)))
    
    if @sickness > 0
      @sickness = @sickness + 1 + (10 /(31 - @age) * 3)
    else
      @sickness = rand(20 / (31 - @age) * 3)
      if @sickness <= 0
        @sickness = 0
      end
    end
    
    if @age > (3 + @sickness) && @age < 8
      @apples = @age * 4 * (@height / 12) - @sickness * rand(11)
    elsif @age >= 8 && @age < 20
      @apples = @age * 4 * (@height / 12) - @sickness * rand(31)
    elsif @age >= 20
      @apples = @age * 4 * (@height / 18) - @sickness * rand(71)
    end
    
    puts "The Apple Tree is now #{@age} years old."
    puts
  end
  end
  
  profile "care" do
  def care
    puts "You prune it, and dig about it, and nourish it."
    if @sickness >= 2
      @sickness = @sickness - rand(3)
    else
      @sickness = 0
    end
    puts "The tree looks happier."
  end
  end
  
  profile "water" do
  def water
    puts "You water the tree."
    if @sickness >= 1
      @sickness = @sickness - rand(2)
    else
      @sickness = 0
    end
    puts "The tree looks refreshed."
  end
  end
  
  profile "pick an apple" do
  def pick_an_apple
    if @apples > 0
      puts "You pick an apple to eat."
      if    @sickness == 0
        puts "It's the most delicious thing you have ever tasted."
      elsif @sickness < 3
        puts "It's a tasty apple."
      elsif @sickness < 6
        puts "It's not very good..."
      else
        puts "It's absolutely disgusting!"
      end
      @apples = @apples - 1
    else
      puts "You try to pick an apple."
      puts "There are no apples to pick!"
    end
  end
  end
  
  profile "cheat" do
  def cheat
    puts @sickness
  end
  end
end

tree = AppleTree.new
while true
  tree.height
  tree.count_apples
  tree.care
  tree.water
  tree.pick_an_apple
  #tree.count_apples
  tree.cheat
  tree.one_year_passes
end