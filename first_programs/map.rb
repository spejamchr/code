class Map
  attr_accessor :vert_size, :hori_size, :tiles, :city_count

  def initialize(vert_size,hori_size)
    @vert_size = vert_size
    @hori_size = hori_size
    @tiles =
      (0...vert_size).map{ |row|
        (0...hori_size).map{ |column|
          Tile.new(type: :ground, column: column, row: row, max_row: vert_size-1, max_column: hori_size-1).characterize
        }
      }
    @city_count = 0
  end

  def row(num)
    tiles[num]
  end

  def column(num)
    tiles.map{|row| row[num]}
  end

  def tile(position) # position = {row: row, column: column}
    tiles[position[:row]][position[:column]]
  end

  def show
    print "\n" + "┌" + ("─" * hori_size) + "┐"
    tiles.each do |row|
      print "\n│"
      row.each do |tile|
        tile.show
      end
      print '│'
    end
    print "\n" + "└" + ("─" * hori_size) + "┘"
    puts
  end

  def neighbors_of(place)
    neighbors = []
    place.neighbors.keys.each{|key| neighbors << tile(place.neighbors[key])}
    neighbors
  end

  def populate
    if tiles.flatten.map(&:type).include?(:ground)
      city = tile({row: rand(vert_size), column: rand(hori_size)})
      if city.type == :ground
        city.type = :city
        self.city_count = self.city_count + 1
        city.characterize(city_count)
        city.nation_id = city_count
        roadadize(city)
      else
        populate
      end
    end
    self
  end

  def roadadize(place)
    unless neighbors_of(place).map(&:type).include?(:ground)
      return
    else
      key = place.neighbors.keys[rand(place.neighbors.count)]
      road = self.tile(place.neighbors[key])
      if road.type == :ground
        road.type = :road
        road.nation_id = city_count
        road.characterize
        roadadize(road)
      elsif road.nation_id != place.nation_id
        #stop
      else
        roadadize(place)
      end
    end
  end

end

class Tile
  attr_accessor :type, :character, :row, :column, :max_row, :max_column, :nation_id

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def *(num)
    (1..num).map{self.dup}
  end

  def characterize(count = nil)
    @character = case type
    when :ground
      if rand > 0.9
        if rand > 0.7
          '.'
        else
          ','
        end
      else
        ' '
      end

    when :city
      (count%10).to_s
      'C'

    when :road
      (nation_id%10).to_s

    else
      'h'
    end
    self
  end

  def show
    print @character
  end

  def neighbors
    unless @neighbors
      @neighbors = {}
      @neighbors[:up] = {row: row-1, column: column} if row > 0
      @neighbors[:right] = {row: row, column: column+1} if column < max_column
      @neighbors[:down] = {row: row+1, column: column} if row < max_row
      @neighbors[:left] = {row: row, column: column-1} if column > 0
    end
    @neighbors
  end

end

map = Map.new(21,78)
puts "--------- Size: ---------"
p map.vert_size
p map.hori_size
puts "--------- First Tile Type: ---------"
p map.tiles.first.first.type
map.show

map.populate.show
map.populate.show
map.populate.show
