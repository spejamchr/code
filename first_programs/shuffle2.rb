def shuffle(string,j,n)
  i = j
  until n < string.length
    n /= 2
  end
  group = string.length/n
  array = string.chars
  big_array = []
  oth_array = []
  mor_array = []
  (string.length/group+1).times do
    stringy = array.shift(group).join
    big_array << stringy if (i % 3 == 0)
    oth_array << stringy if (i % 3 == 1)
    mor_array << stringy if (i % 3 == 2)
    i += 1
  end

  array = big_array+oth_array+mor_array
  array.join
end

def shuffler(s)
  string = shuffle(s,1,1)
  string = shuffle(s,1,2)
  string = shuffle(string,1,3)
  string = shuffle(string,1,4)
  string = shuffle(string,1,5)
  string = shuffle(string,1,6)
  string = shuffle(string,1,7)
end

def anti_shuffle(string,j,n)
  i = j
  result = string
  if string.length >= n
    group = string.length/n
    array = string.split('')
    big_array = []
    oth_array = []
    (string.length/group+1).times do
      stringy = array.shift(group).join
      big_array << stringy if (i % 2 == 1)
      oth_array << stringy if (i % 2 == 0)
      i += 1
    end
    array = big_array+oth_array
    # array = array.map do |string|
#       anti_shuffle(string,i,n)
#     end
    result = array.join
  end
  result
end
a = shuffle('abcdefghijklmnopqrstuvwxyz',1,3)
p a
p shuffler('abcdefghijklmnopqrstuvwxyz')
b = anti_shuffle(a,1,3)
p b






#efghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ
