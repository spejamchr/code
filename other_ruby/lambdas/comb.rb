# frozen_string_literal: true

# Jot
# Syntax:        Semantics:
# F --> e        ^x.x
# F --> F  0     [F]SK
# F --> F  1     ^xy.[F](xy)
#
# T[x] => x
# T[(E₁ E₂)] => (T[E₁] T[E₂])
# T[λx.E] => (K T[E]) (if x does not occur free in E)
# T[λx.x] => I
# T[λx.λy.E] => T[λx.T[λy.E]] (if x occurs free in E)
# T[λx.(E₁ E₂)] => (S T[λx.E₁] T[λx.E₂]) (if x occurs free in E₁ or E₂)

# Take a lamba term string, and convert it to SKI calculus
#
# Lambda term syntax:
#
# L => x          (Variables)
# L => ^x.L       (Abstraction. Where x is a free variable)
# L => (L L)      (Application)
#
# So these are valid:
# ^x.(x y)
# ^x.^y.(x ^z.(y z))
#
# And these are not valid:
# ^x y.y          # functions only take one argument
# ^x x            # Bad syntax
# ^x.^x.x         # `x` is not free in the inner function
# ^x.^y.^z.x y z  # Parentheses please
#
# Also, variable names should only use letters and underscores
def lamb_to_comb(lamb)
  # puts "lamb_to_comb('#{lamb}')"
  case lamb
  when /^[a-z_]+$/i # Variable
    lamb
  when /^\((.+)\)$/i # Application
    a, b = find_groups($1)
    "(#{lamb_to_comb(a)} #{lamb_to_comb(b)})"
  when /^\^([a-z_]+)\.(.+)$/i # Abstraction
    variable = $1
    expression = $2
    if !expression.match?(/#{variable}/)
      "(K #{lamb_to_comb(expression)})"
    elsif expression == variable
      "I"
    elsif /^\^([a-z_]+)\.(.+)$/i === expression
      var2 = $1
      expression2 = $2
      if expression2 == variable
        'K'
      elsif /^\^([a-z_]+)\.(.+)$/i === expression2
        var3 = $1
        expression3 = $2
        s = "((#{variable} #{var3}) (#{var2} #{var3}))"
        if expression3 == s
          'S'
        else
          lamb_to_comb("^#{variable}.#{lamb_to_comb(expression)}")
        end
      else
        lamb_to_comb("^#{variable}.#{lamb_to_comb(expression)}")
      end
    elsif /^\((.+)\)$/i === expression
      a, b = find_groups($1)
      a, b = "^#{variable}.#{a}", "^#{variable}.#{b}"
      "((S #{lamb_to_comb(a)}) #{lamb_to_comb(b)})"
    else
      raise "invalid lambda expression: #{expression}"
    end
  else
    raise "invalid lambda: #{lamb}"
  end
end

def test_lamb_to_comb(const)
  print "\n[test] #{const}: "
  str = lamb_to_comb(Kernel.const_get(const))
  if str.match?(/^[SKI\(\) ]+$/)
    puts str
  else
    raise "INVALID SKI Expression:\n  #{str}"
  end
end

# Converting SK to Jot
# {K}     ->   11100
# {S}     ->   11111000
# {AB}    ->   1{A}{B}
def comb_to_jot(comb)
  case comb
  when /^I$/
    comb_to_jot('((S K) K)')
  when /^K$/
    '11100'
  when /^S$/
    '11111000'
  else
    a, b = find_groups(comb[1..-2])
    "1#{comb_to_jot(a)}#{comb_to_jot(b)}"
  end
end

def group_split_index(groups)
  i = 1
  g = 1
  while g > 0
    g += 1 if groups[i] == '('
    g -= 1 if groups[i] == ')'
    i += 1
  end
  i
end

def find_groups(groups)
  # puts "find_groups('#{groups}')"
  case groups
  when /^\^[a-z_]+\./i # The first item is an abstraction
    # puts "It's an abstraction"
    i = 0
    g = 0
    until g == 0 && groups[i] == ' '
      g += 1 if groups[i] == '('
      g -= 1 if groups[i] == ')'
      i += 1
    end
    a = groups[0..i-1]
    b = groups[i+1..-1]
    [a, b]
  when /^\(.+\)$/
    i = group_split_index(groups)
    a = groups[0..i-1]
    b = groups[i+1..-1]
    [a, b]
  when /^\(.+[^\)]$/
    a, _, b = groups.rpartition(' ')
    [a, b]
  when /^[^\(].+\)$/
    a, _, b = groups.partition(' ')
    [a, b]
  when /^[^\(].+[^\)]$/
    groups.split(' ')
  end
end

K = ->(a) { ->(_) { a } }
S = ->(x) { ->(y) { ->(z) { x[z][y[z]] } } }

def jot(str)
  str.split('').inject(->(x) { x }) do |v, b|
    if b == '1'
      ->(f) { ->(a) { v[f[a]] } }
    else
      v[S][K]
    end
  end
end

def jots(str, v = '-> x { x }')
  return v if str == ''

  if str[0] == '1'
    jots(str[1..-1], "->(f) { ->(a) { #{v}[f[a]] } }")
  else
    jots(str[1..-1], "#{v}[S][K]")
  end
end

def jot_to_i(str)
  jot(str)[->(n) { n + 1 }][0]
end

def comb_to_i(str)
  jot_to_i(comb_to_jot(str))
end

def lamb_to_i(str)
  comb_to_i(lamb_to_comb(str))
end

def jot_to_boolean(str)
  # puts "jot_to_boolean('#{str}')"
  a = ->(_) { a }
  b = ->(_) { b }
  jot(str)[a][b] == a
end

def comb_to_boolean(str)
  jot_to_boolean(comb_to_jot(str))
end

def lamb_to_boolean(str)
  comb_to_boolean(lamb_to_comb(str))
end

def jot_to_a(str)
  array = []
  jot(str)[
    ->(n) {
      puts "array before: #{array}"
      array << n
      puts "array after: #{array}"
      ->(a) { a }
    }
  ][->(a) { a }]
  puts "jot_to_a: #{array}"
  array
end

CHARSET = '0123456789BFiuz'.chars.entries # for encoding digits, "Fizz" and "Buzz"
def i_to_char(i)
  CHARSET.at(i)
end

def jot_to_char(str)
  i_to_char(jot_to_i(str))
end

def jot_to_s(str)
  jot_to_a(str).map { |char| i_to_char(char[->(n) { n + 1 }][0]) }.join
end

def comb_to_s(str)
  jot_to_s(comb_to_jot(str))
end

def lamb_to_s(str)
  comb_to_s(lamb_to_comb(str))
end

def jot_to_comb(str, v = 'I')
  return v if str == ''

  if str[0] == '1'
    jot_to_comb(str[1..-1], lamb_to_comb("^x.^y.(#{v} (x y ))"))
  else
    jot_to_comb(str[1..-1], "((#{v} S) K)")
  end
end

def rand_word
  5.times.map { (('a'..'z').to_a + ('A'..'Z').to_a).sample }.join
end

# Mangles variable names in expressions
def m(expr)
  vars =
    expr
    .scan(/[a-z_]+/i)
    .uniq

  num_expr =
    vars
    .each
    .with_index
    .inject(expr) { |e, (c, i)| e.gsub(c, i.to_s) }

  (vars.count - 1)
    .downto(0)
    .inject(num_expr) { |e, i| e.gsub(i.to_s, rand_word) }
end

# Y := λg.(λx.g (x x)) (λx.g (x x))
Y = '^f.(^x.(f (x x)) ^x.(f (x x)))'

ZERO = '^x.^y.y'
ONE = '^x.^y.(x y)'
TWO = '^x.^y.(x (x y))'
THREE = '^x.^y.(x (x (x y)))'
FOUR = '^x.^y.(x (x (x (x y))))'
FIVE = '^x.^y.(x (x (x (x (x y)))))'

test_lamb_to_comb :ZERO
test_lamb_to_comb :ONE
test_lamb_to_comb :TWO
test_lamb_to_comb :THREE
test_lamb_to_comb :FOUR
test_lamb_to_comb :FIVE

INCREMENT = '^n.^x.^y.(x ((n x) y))'
PLUS = '^m.^n.^f.^x.((m f) ((n f) x))'
MULT = '^m.^n.^f.^x.((m (n f)) x)'
EXP = '^m.^n.(n m)'
DECREMENT = '^n.^f.^x.(((n ^g.^h.(h (g f))) ^u.x) ^u.u)'
SUBTRACT = "^m.^o.((o #{m DECREMENT}) m)"

test_lamb_to_comb :INCREMENT
test_lamb_to_comb :PLUS
test_lamb_to_comb :MULT
test_lamb_to_comb :EXP
test_lamb_to_comb :DECREMENT
test_lamb_to_comb :SUBTRACT

TRUE_ = '^f.^s.f'
FALSE_ = '^f.^s.s'
NOT = '^b.^f.^s.((b s) f)'
AND = '^ba.^bb.((ba bb) ba)'

test_lamb_to_comb :TRUE_
test_lamb_to_comb :FALSE_
test_lamb_to_comb :NOT
test_lamb_to_comb :AND

IS_ZERO = "^n.((n ^x.#{m FALSE_}) #{m TRUE_})"
IS_LESS_OR_EQUAL = "^m.^n.(#{m IS_ZERO} ((#{m SUBTRACT} m) n))"
IS_EQUAL = "^m.^n.((#{m AND} ((#{m IS_LESS_OR_EQUAL} m) n)) ((#{m IS_LESS_OR_EQUAL} n) m))"

test_lamb_to_comb :IS_ZERO
test_lamb_to_comb :IS_LESS_OR_EQUAL
test_lamb_to_comb :IS_EQUAL

MINIMOD = "^mod.^n.^q.((((#{m IS_LESS_OR_EQUAL} n) q) ((mod ((#{m SUBTRACT} n) q)) q)) n)"
MOD = "(#{m Y} #{m MINIMOD})"

test_lamb_to_comb :MINIMOD
test_lamb_to_comb :MOD

MINIDIV = "^div.^n.^q.((((#{m IS_LESS_OR_EQUAL} n) q) (#{m INCREMENT} ((div ((#{m SUBTRACT} n) q)) q))) #{m ZERO})"
DIV = "(#{m Y} #{m MINIDIV})"

test_lamb_to_comb :MINIDIV
test_lamb_to_comb :DIV

# Pairs
PAIR = '^a.^b.^f.((f a) b)'
FIRST = '^p.(p ^a.^b.a)'
SECOND = '^p.(p ^a.^b.b)'

test_lamb_to_comb :PAIR
test_lamb_to_comb :FIRST
test_lamb_to_comb :SECOND

# Lists
# EMPTY_LIST = "((#{m PAIR} #{m TRUE_}) #{m TRUE_})"
# IS_EMPTY = FIRST
# CONS = "^h.^t.((#{m PAIR} #{m FALSE_}) ((#{m PAIR} h) t))"
# HEAD = "^l.(#{m FIRST} (#{m SECOND} l))"
# TAIL = "^l.(#{m SECOND} (#{m SECOND} l))"

EMPTY_LIST = '^c.^n.n'
IS_EMPTY = "^l.((l ^h.^t.#{m FALSE_}) #{m TRUE_})"
CONS = '^h.^t.^c.^n.((c h) ((t c) n))'
HEAD = "^l.((l ^h.^t.h) #{m FALSE_})"
TAIL = '^l.^c.^n.(((l ^h.^t.^g.((g h) (t c))) ^t.n) ^h.^t.t)'

FOLD_RIGHT = PAIR
MAP = "^f.((#{m FOLD_RIGHT} ^x.(#{m CONS} (f x))) #{m EMPTY_LIST})"

test_lamb_to_comb :EMPTY_LIST
test_lamb_to_comb :IS_EMPTY
test_lamb_to_comb :CONS
test_lamb_to_comb :HEAD
test_lamb_to_comb :TAIL
test_lamb_to_comb :FOLD_RIGHT
test_lamb_to_comb :MAP

MINIRANGE = "^range.^min.^max.((((#{m IS_LESS_OR_EQUAL} min) max) ((#{m CONS} min) ((range (#{m INCREMENT} min)) max))) #{m EMPTY_LIST})"
RANGE = "(#{m Y} #{m MINIRANGE})"
APPEND = "(#{m FOLD_RIGHT} #{m CONS})"
PUSH = "^value.(#{m APPEND} ((#{m CONS} value) #{m EMPTY_LIST}))"
REVERSE = "((#{m FOLD_RIGHT} #{m PUSH}) #{m EMPTY_LIST})"

test_lamb_to_comb :MINIRANGE
test_lamb_to_comb :RANGE
test_lamb_to_comb :APPEND
test_lamb_to_comb :PUSH
test_lamb_to_comb :REVERSE

NINE = '^x.^y.(x (x (x (x (x (x (x (x (x y)))))))))'
TEN = '^x.^y.(x (x (x (x (x (x (x (x (x (x y))))))))))'
B_ = TEN
F_ = '^x.^y.(x (x (x (x (x (x (x (x (x (x (x y)))))))))))' # 11
I_ = '^x.^y.(x (x (x (x (x (x (x (x (x (x (x (x y))))))))))))' # 12
U_ = '^x.^y.(x (x (x (x (x (x (x (x (x (x (x (x (x y)))))))))))))' # 13
Z_ = '^x.^y.(x (x (x (x (x (x (x (x (x (x (x (x (x (x y))))))))))))))' # 14
FIFTEEN = '^x.^y.(x (x (x (x (x (x (x (x (x (x (x (x (x (x (x y)))))))))))))))'
HUNDRED = '^x.^y.(x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x (x y))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))'

test_lamb_to_comb :NINE
test_lamb_to_comb :TEN
test_lamb_to_comb :B_
test_lamb_to_comb :F_
test_lamb_to_comb :I_
test_lamb_to_comb :U_
test_lamb_to_comb :Z_
test_lamb_to_comb :FIFTEEN
test_lamb_to_comb :HUNDRED

MINI_TO_DIGITS =  "^to_digits.^n.((#{m PUSH} ((#{m MOD} n) #{m TEN})) ((((#{m IS_LESS_OR_EQUAL} n) #{m NINE}) #{m EMPTY_LIST}) (to_digits ((#{m DIV} n) #{m TEN}))))"
TO_DIGITS = "(#{m Y} #{m MINI_TO_DIGITS})"
TO_STRING = TO_DIGITS

test_lamb_to_comb :MINI_TO_DIGITS
test_lamb_to_comb :TO_DIGITS
test_lamb_to_comb :TO_STRING

FIZZ = "((#{m CONS} #{m F_}) ((#{m CONS} #{m I_}) ((#{m CONS} #{m Z_}) ((#{m CONS} #{m Z_}) #{m EMPTY_LIST}))))"
BUZZ = "((#{m CONS} #{m B_}) ((#{m CONS} #{m U_}) ((#{m CONS} #{m Z_}) ((#{m CONS} #{m Z_}) #{m EMPTY_LIST}))))"

test_lamb_to_comb :FIZZ
test_lamb_to_comb :BUZZ

FIZZBUZZ =
  "((#{m MAP} ^num.(((#{
    m IS_ZERO} ((#{m MOD} num) #{m FIFTEEN})) ((#{
      m APPEND} #{m BUZZ}) #{m FIZZ})) (((#{
    m IS_ZERO} ((#{m MOD} num) #{m THREE})) #{
      m FIZZ}) (((#{
    m IS_ZERO} ((#{m MOD} num) #{m FIVE})) #{
      m BUZZ}) (#{m TO_STRING} num))))) ((#{
  m RANGE} #{m ONE}) #{m HUNDRED}))"

test_lamb_to_comb :FIZZBUZZ

DIG64 = (0..9).map(&:to_s) + ('a'..'z').to_a + ('A'..'Z').to_a + ['~', '-']
def to_64(bin_str)
  n = bin_str.to_i(2)
  return '0' if n == 0
  digs = []
  while n > 0
    digs << DIG64[n % 64]
    n /= 64
  end
  digs.reverse.join
end

puts
puts "Test ZERO: #{lamb_to_i(ZERO)}"
puts "Test ONE: #{lamb_to_i(ONE)}"
puts "Test TWO: #{lamb_to_i(TWO)}"
puts "Test THREE: #{lamb_to_i(THREE)}"
puts "Test ((PLUS THREE) TWO): #{lamb_to_i "((#{m PLUS} #{m THREE}) #{m TWO})"}"
puts "Test ((PLUS THREE) TWO): #{lamb_to_i "((#{m MULT} #{m THREE}) #{m TWO})"}"
puts "Test ((SUBTRACT THREE) TWO): #{lamb_to_i "((#{m SUBTRACT} #{m THREE}) #{m TWO})"}"
puts "Test ((SUBTRACT TWO) THREE): #{lamb_to_i "((#{m SUBTRACT} #{m TWO}) #{m THREE})"}"
puts "Test ((EXP FIVE) THREE): #{lamb_to_i "((#{m EXP} #{m FIVE}) #{m THREE})"}"
puts
puts "Test TRUE_: #{lamb_to_boolean(TRUE_)}"
puts "Test FALSE_: #{lamb_to_boolean(FALSE_)}"
puts "TEST (NOT TRUE_): #{lamb_to_boolean "(#{m NOT} #{m TRUE_})"}"
puts "TEST (NOT FALSE_): #{lamb_to_boolean "(#{m NOT} #{m FALSE_})"}"
puts "TEST ((AND TRUE_) TRUE_): #{lamb_to_boolean "((#{m AND} #{m TRUE_}) #{m TRUE_})"}"
puts "TEST ((AND FALSE_) TRUE_): #{lamb_to_boolean "((#{m AND} #{m FALSE_}) #{m TRUE_})"}"
puts "TEST ((AND TRUE_) FALSE_): #{lamb_to_boolean "((#{m AND} #{m TRUE_}) #{m FALSE_})"}"
puts "TEST ((AND FALSE_) FALSE_): #{lamb_to_boolean "((#{m AND} #{m FALSE_}) #{m FALSE_})"}"
puts
puts "TEST EMPTY_LIST: #{comb_to_jot lamb_to_comb(EMPTY_LIST)}"
puts "TEST ((CONS Z_) EMPTY_LIST): #{comb_to_jot lamb_to_comb("((#{m CONS} #{m Z_}) #{m EMPTY_LIST})")}"
puts "TEST FIZZ: #{comb_to_jot lamb_to_comb(FIZZ)}"
puts "TEST BUZZ: #{comb_to_jot lamb_to_comb(BUZZ)}"
puts "TEST ((APPEND BUZZ) FIZZ): #{comb_to_jot lamb_to_comb("((#{m APPEND} #{m BUZZ}) #{m FIZZ})")}"
puts
puts "TEST EMPTY_LIST: #{EMPTY_LIST}"
puts "TEST ((CONS Z_) EMPTY_LIST): #{"((#{m CONS} #{m Z_}) #{m EMPTY_LIST})"}"
puts "TEST FIZZ: #{FIZZ}"
puts "TEST BUZZ: #{BUZZ}"
puts "TEST ((APPEND BUZZ) FIZZ): #{"((#{m APPEND} #{m BUZZ}) #{m FIZZ})"}"
puts
puts "TEST EMPTY_LIST: #{lamb_to_s(EMPTY_LIST)}"
puts "TEST ((CONS Z_) EMPTY_LIST): #{lamb_to_s("((#{m CONS} #{m Z_}) #{m EMPTY_LIST})")}"
puts "TEST FIZZ: #{lamb_to_s(FIZZ)}"
puts "TEST BUZZ: #{lamb_to_s(BUZZ)}"
puts "APPEND: #{APPEND}"
puts "FOLD_RIGHT: #{FOLD_RIGHT}"
puts "CONS: #{CONS}"
puts "TEST ((APPEND BUZZ) FIZZ): #{"((#{m APPEND} #{m BUZZ}) #{m FIZZ})"}"
puts "TEST ((APPEND BUZZ) FIZZ): #{lamb_to_s("((#{m APPEND} #{m BUZZ}) #{m FIZZ})")}"
puts
puts "FIZZBUZZ: #{comb_to_jot(lamb_to_comb(FIZZBUZZ))}"
puts "FIZZBUZZ: #{jot comb_to_jot(lamb_to_comb(FIZZBUZZ))}"
