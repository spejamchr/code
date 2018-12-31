class Town
  attr_accessor :name, :number

  def self.all
    @towns ||= []
  end

  def self.set_numbers
    all.each(&:set_number)
    self
  end

  def self.show
    print 'Towns:      '
    puts all.map(&:name).join(' ')
    print 'Numbers:    '
    puts all.map(&:number).map{|n| n.round(1) }.join(' ')
    print 'Population:   '
    puts all.map(&:people).map(&:count).join('   ')
    (0...all.map{|t| t.people.count}.max).each do |i|
      print 'People Num:  '
      puts all.map{|t| t.people[i] ? t.people[i].number : '_' }.join('   ')
    end
  end

  def initialize(name)
    @name = name
    Town.all << self
  end

  def set_number
    if people.empty?
      @number = rand(Person::MAX_NUMBER)
    else
      @number = people.map(&:number).inject(&:+)/(people.count.to_f)
    end
  end

  def people
    Person.all.select{|per| per.town == self}
  end

  def new_people(num)
    people = []
    num.times{people << Person.new('rand', self)}
    people
  end

end

class Person
  MAX_NUMBER = 100
  attr_accessor :number, :town

  def self.all
    @people ||= []
  end

  def self.move
    Person.all.each(&:move)
    Town.set_numbers
  end

  def initialize(name, town)
    @name = name
    @town = town
    Person.all << self
    @number = rand(MAX_NUMBER)
  end

  def other_town
    Town.all.select{|t| t != self.town}.first
  end

  def move
    home_dist = (number - town.number).abs
    other_dist = (number - other_town.number).abs
    if home_dist + other_dist != 0 # no dividing by zero!
      stay_home = other_dist/(home_dist + other_dist)
    else
      stay_home = 0.5
    end
    if stay_home > rand
      # stay home
    else
      self.town = other_town # move
    end
  end
end

tin = Town.new('Tin')
mit = Town.new('Mit')
tin.new_people(3)
mit.new_people(3)
a = tin.new_people(70)
a.each{|p| p.number = 0}
b = mit.new_people(70)
b.each{|p| p.number = 100}

Town.set_numbers
numbers = [Town.all.map(&:number)]
300.times do
  Person.move
  numbers << [Town.all.map(&:number)]
end

numbers.each{|n| puts n.join("\t")}
