a = [[1, 7], [2, 4], [6, 8]]

sum = 0

i = 0
while i < a.count
  if a[i+1] && a[i][1] > a[i+1][0]
    joined = (a[i+1]+a[i]).sort
    sum += joined.last - joined.first
    i += 2
  else
    sum += a[i][1]-a[i][0]
    i +=1
  end
end

p sum



finished = []
a.sort!
(0..a.count-1).each do |i|
  if a[i]
    while a[i+1] && a[i][1] > a[i+1][0]
      a[i][1] = a[i+1][1]
      a.delete_at(i+1)
    end
  end
end
sum = a.map{|arr| arr.last-arr.first}.inject(:+)
p sum



[[1, 3],[2,4],[5,7],[6,8]].reduce([[0,0]]) { |memo, (s, e)|
  if memo.last.last > s
    if memo.last.last < e
      memo.last[1] = e
    end
  else
    memo << [s,e]
  end
  memo
}.map { |s,e| e - s }.reduce(:+)


puts
puts



a = [[1,5],[2,3],[3,6],[7,8]]

s, e = a[0]