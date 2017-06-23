m = 'land'
o = 'water'
world = [[o,o,o,o,o,m,o,o,o,o,o],
         [o,o,o,o,m,o,o,o,o,o,o],
         [o,o,o,m,o,o,o,o,m,m,o],
         [o,o,o,m,o,o,o,o,o,m,o],
         [o,o,o,m,o,m,m,o,o,o,o],
         [m,o,o,o,m,m,m,m,o,o,o],
         [o,m,m,m,m,o,m,m,m,m,m],
         [o,o,o,o,o,o,m,m,o,o,o],
         [o,m,o,o,o,m,o,o,o,o,o],
         [o,o,o,o,o,m,o,o,o,o,o],
         [o,o,o,o,o,m,o,o,o,o,o]]

def continent_size world, x, y
  return 0 if world [y][x] != 'land'
  size = 1
  world [y][x] = 'counted land'

  size += continent_size(world, x - 1, y) if world[y][x - 1] == 'land'
  size += continent_size(world, x + 1, y) if world[y][x + 1] == 'land'
  size += continent_size(world, x, y - 1) if world[y - 1][x] == 'land'
  size += continent_size(world, x, y + 1) if world[y + 1][x] == 'land'

  size
end

puts continent_size(world, 5, 5)

world.each do |row|
  row.each { |c| print c[0] }
  print "\n"
end
