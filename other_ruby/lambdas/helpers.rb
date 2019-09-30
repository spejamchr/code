load './structures.rb'

def to_integer(lamb)
  counter = 0
  lamb.reduce[-> _ { counter += 1; _ }][3].reduce
  counter
end

def to_boolean(lamb)
  lamb.reduce[true][false].reduce
end

def to_array(l)
  array = []
  l = l.reduce

  until to_boolean(IS_NULL[l])
    array.push(HEAD[l].reduce)
    l = TAIL[l].reduce
  end

  array
end

CHARSET = '0123456789BFiuz'.chars.entries # for encoding digits, "Fizz" and "Buzz"

def to_char(c)
  CHARSET.at(to_integer(c))
end

def to_string(s)
  to_array(s).map { |c| to_char(c) }.join
end

def matches(name, lamb, string)
  return if lamb.inspect == string

  puts "(#{name}) Expected these to be equal:"
  puts '  ' + lamb.inspect
  puts '  ' + string
end
