load './structures.rb'

def to_integer(lamb)
  counter = 0
  lamb[-> _ { counter += 1; _ }][3].reduce
  counter
end

def to_boolean(lamb)
  lamb[true][false].reduce
end

def to_array(l)
  array = []

  until to_boolean(IS_NULL[l])
    array.push(HEAD[l])
    l = TAIL[l]
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
