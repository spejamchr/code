require 'matrix'

x_s = Matrix[[424715.5721, 424916.7420, 424588.5560, 424891.0929, 424623.5067,
              424781.8765, 424820.5984, 424545.8968, 424672.7868, 424677.0031,
              424573.4230, 424868.9239, 424883.6243, 424854.7811, 424603.5072]]
            
y_s = Matrix[[4513706.050, 4513699.553, 4513754.538, 4513725.530, 4513734.264,
              4513710.899, 4513718.604, 4513690.374, 4513731.795, 4513767.828,
              4513681.366, 4513723.863, 4513694.155, 4513716.169, 4513706.082]]
            
z_s = Matrix[[1351.624006, 1355.527048, 1364.539930, 1356.005992, 1358.831667,
              1349.468615, 1348.868995, 1340.328068, 1335.475833, 1347.053974,
              1346.474556, 1354.031923, 1342.580290, 1358.047861, 1348.815801]]

def factorial(n)
  if n <= 1
    1
  else
    n * factorial(n-1)
  end
end

def n_choose_k(n,k)
  factorial(n)/(factorial(k)*factorial(n-k))
end

# Paths--each combination of two points, ie, [0,0],[0,1],[1,2] etc
def paths(points)
  paths = []
  (0...(points.count-1)).each do |point_1|
    ((point_1+1)...points.count).each do |point_2|
      paths << [point_1,point_2]
    end
  end
  paths
end

paths = paths(x_s)

def distances(x_s,y_s,z_s)
  distances = []
  (0...(x_s.count-1)).each do |p1|
    ((p1+1)...x_s.count).each do |p2|
      distances << ((x_s[0,p1]-x_s[0,p2])**2+(y_s[0,p1]-y_s[0,p2])**2+(z_s[0,p1]-z_s[0,p2])**2)**(0.5)
    end
  end
  distances
end

distances = distances(x_s,y_s,z_s)

class Array
  
  def has_how_many_points_in(points)
    counter = 0
    (0...(points.count-1)).each do |i|
      counter += 1 if points.include? [self[i], self[i+1]]
      counter += 1 if points.include? [self[i+1], self[i]]
    end
    counter
  end
  
end

### Find my_points, the list of paired points ###
def my_points(distances,paths,x_s,subroutines=nil)
  if distances.uniq == distances
    sorted = distances.sort
  end
  points = Array.new(x_s.count){0}

  i = 0
  my_dists = []
  my_points = []
  while points != Array.new(x_s.count){2} && sorted[i] != nil
    p1, p2 = paths[distances.index(sorted[i])]
    
    usable = true
    if subroutines
      subroutines.each do |sub|
        if sub.has_how_many_points_in(my_points) >= (sub.count - 1)
          usable = false
        end
      end
    end
    
    if points[p1] < 2 && points[p2] < 2 && usable
      my_dists << sorted[i]
      my_points << [p1,p2]
      points[p1] += 1
      points[p2] += 1
      p points
      p my_points
      puts
    end
    if (i + 1) < sorted.count
      i += 1
    else
      i = 0
    end
  end
  [my_points, my_dists]
end

my_points, my_dists = my_points(distances,paths,x_s)

puts "path: #{my_points.sort}"

puts "Total Distance: #{my_dists.inject(:+)}"


def sub_routines(array)
  my_points = array.sort
  sub_routines = []
  sub_routines[0] = []
  i = 0
  j = 0
  k = 0
  while my_points != []
    p1 = my_points[i][j]
    sub_routines[k] << p1
    p2 = my_points[i][j-1]
    if j == 0
      my_points.delete([p1,p2])
    elsif j == 1
      my_points.delete([p2,p1])
    end
    
    finish = true
    my_points.each_with_index do |pt,index|
      if pt[0] == p2
        i = index
        j = 0
        finish = false
      elsif pt[1] == p2
        i = index
        j = 1
        finish = false
      end
    end
    if finish
      k += 1
      j = 0
      i = 0
      sub_routines[k] = [] unless my_points == []
    end
  end
  sub_routines
end
puts
puts
puts
sub_routines = sub_routines(my_points)

list_of_sub_routines = []

sub_routines.each do |i|
  list_of_sub_routines << i
end


p list_of_sub_routines

puts
puts
puts 'do it again!'
puts
puts


my_points, my_dists = my_points(distances,paths,x_s,list_of_sub_routines)

puts "my_points (path): #{my_points.sort}"

puts "Total Distance: #{my_dists.inject(:+)}"

sub_routines = sub_routines(my_points)

list_of_sub_routines = []

sub_routines.each do |i|
  list_of_sub_routines << i
end

p list_of_sub_routines