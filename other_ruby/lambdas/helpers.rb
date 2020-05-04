load './structures.rb'

def to_integer(lamb)
  counter = 0
  lamb.reduce[-> _ { counter += 1; _ }][3].reduce
  counter
end

def to_boolean(lamb)
  lamb.reduce[2][1].reduce.term == 2
end

def to_array(l)
  array = []

  l.reduce[->(n) {
    puts to_string(n)
    array << n
    ->(a) { a }
  }][->(a) { a }].reduce

  array
end

def to_clean_array(l)
  array = []

  l.reduce[->(n) {
    array << n
    ->(a) { a }
  }][->(a) { a }].reduce

  array
end

CHARSET = '0123456789BFiuz'.chars.entries # for encoding digits, "Fizz" and "Buzz"

def to_char(c)
  CHARSET.at(to_integer(c))
end

def to_string(s)
  to_clean_array(s).map { |c|
    counter = 0
    c[->(_) { counter += 1; _ }][->(a) { a }].reduce
    CHARSET.at(counter)
  }.join
end

def matches(name, lamb, string)
  return if lamb.inspect == string

  puts "(#{name}) Expected these to be equal:"
  puts '  ' + lamb.inspect
  puts '  ' + string
end
