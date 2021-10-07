# Map all pairs of integers to unique integers
def d2(x, y)
  n = [x.abs, y.abs].max
  # dist = (n - x) + (n - y)
  dist = 2 * n - x - y
  r = x > y ? (n * 2 - 1)**2 + dist : (n * 2 + 1)**2 - dist
  h, i = r.divmod(2)
  h * (i * -2 + 1)
  r
  dist
end

(-1..1).each do |x|
  (-1..1).each do |y|
    next print ' ' * 4 if x == y && x.zero?
    print d2(x, y).to_s.rjust(4)
  end
  puts
end

# Map all "corner pieces" to unique integers 0-7
#
# a triplet `a` is a "corner piece" if `a.map(&:abs).uniq.count == 1`
def corner_index(a)
  raise "Not a corner peice" unless a.map(&:abs).uniq.count == 1

  shell = a.first.abs

  case a.sum
  when 3 * shell then 0
  when -3 * shell then 1
  when shell then 2 + a.index(-shell)
  when -shell then 5 + a.index(shell)
  end
end

# Map all "edge pieces" to unique integers 0-11
#
# a triplet `a` is an "edge piece" if `a.map(&:abs).count(a.map(&:abs).max) == 2`
def edge_index(a)
  raise "Not an edge peice" unless a.map(&:abs).count(a.map(&:abs).max) == 2

  abs = a.map(&:abs)

  abs.index(abs.min) +
    case a.count(abs.max)
    when 0 then 0
    when 2 then 3
    when 1 then a[0] > a[1] ? 6 : 9
    end
end

# Map all "face pieces" to unique integers 0-5
#
# a triplet `a` is a "face piece" if `a.map(&:abs).count(a.map(&:abs).max) == 1`
def face_index(a)
  raise "Not a face peice" unless a.map(&:abs).count(a.map(&:abs).max) == 1

  abs = a.map(&:abs)

  abs.index(abs.max) + (a.max_by(&:abs).positive? ? 0 : 3)
end

# Map all triplets of integers to unique integers
def d3(x, y, z)
  a = [x, y, z]
  return 0 if a.all?(&:zero?)

  shell = a.map(&:abs).max
  inner_space = (shell * 2 - 1)**3 + 1
  max_index = (shell * 2 + 1)**3

  r =
    case a.map(&:abs).count(shell)
    when 3 # corner
      index = corner_index(a)
      index < 4 ?
        inner_space + index :
        max_index - (index - 4)
    when 2 # edge
      index = edge_index(a)
      dist = shell - 1 + a.min_by(&:abs)
      edge_length = shell * 2 - 1

      inner_space + 4 + index * edge_length + dist
    when 1 # face
      index = face_index(a)
      face_coors = a.reject { |x| x.abs == shell }
      face_area = (shell * 2 - 1)**2
      dist = d2(*face_coors) + face_area / 2

      max_index - 4 - (index * face_area + dist)
    end

  r / 2 * (r.odd? ? -1 : 1)
end

# Map an array of integers to a single integer (unique across arrays of the same size)
def dn(*array)
  case array.size
  when 0 then 0
  when 1 then array.first
  when 2 then d2(*array)
  when 3 then d3(*array)
  else
    array
      .each_slice((array.count / 2.0).ceil)
      .map { |a| dn(*a) }
      .yield_self { |a| dn(*a) }
  end
end

# range = (-2..2).to_a
# (1..8).each do |n|
#   optimal = range.count**n / 2
#   puts "#{optimal} (#{range.count}**#{n} / 2):"
#   r = range.product(*[range] * (n - 1)).map { |a| dn(*a) }
#   max = r.max_by(&:abs)
#   puts "  #{max}"
#   puts "  (#{max.abs  / optimal} time(s) optimal)"
#   puts "  (broken, not all unique" unless r.count == r.uniq.count
# end

# puts

# range = (-3..3).to_a
# optimal = range.count**3 / 2
# puts "#{optimal} (#{range.count}**3 / 2):"

# ps = range.product(range, range)
# r = ps.map { |a| d3(*a) }
# max = r.max_by(&:abs)

# puts "  #{max}"
# puts "  (#{max.abs  / optimal} time(s) optimal)"
# puts "  (broken, not all unique" unless r.count == r.uniq.count
# puts
