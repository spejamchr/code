# a variable, 1, is itself a valid lambda term
# if t is a lambda term, then l[ t ] is a lambda term (called a lambda abstraction);
# if t and s are lambda terms, then t[s] is a lambda term (called an application).

module LogAround
  def peep(method, &block)
    ali = "_orig_#{method}".to_sym
    alias_method ali, method

    define_method(method) do |*args|
      id = (rand*36**4).to_i.to_s(36)
      puts "[#{id}] Calling #{method} with args #{args.inspect} on #{inspect}"

      result = send(ali, *args)
      yield(result, *args) if block_given?

      puts "[#{id}] Returned #{method} #{result.inspect}"
      result
    end
  end
end

class LambDeBruijn
  extend LogAround

  class << self
    private :new

    def variable(var)
      accepts(var, Integer)
      new({ kind: :variable, term: var })
    end

    def abstraction(term)
      new({ kind: :abstraction, term: wrap(term) })
    end

    def application(term, var)
      new({ kind: :application, term: wrap(term), var: wrap(var) })
    end

    def accepts(var, *klasses)
      if klasses.none? { |k| k === var }
        # raise "Expected one of #{klasses} but got #{var.class}: #{var}"
      end
    end

    def wrap(term, klass = nil)
      klass ||= self
      term = klass.variable(term) if Integer === term
      accepts(term, klass, Proc)
      term
    end
  end

  def initialize(term)
    @expression = term.freeze
  end

  def [](term)
    self.class.application(self, self.class.wrap(term))
  end

  def hashified
    @expression.transform_values do |v|
      self.class === v ? v.hashified : v
    end
  end

  %i[kind term var].each do |key|
    define_method(key) { @expression.fetch(key) }
  end

  %i[variable abstraction application].each do |key|
    define_method(key) { |*a| self.class.public_send(key, *a) }
  end

  def lamb?(thing)
    self.class === thing
  end

  def inspect
    t = Proc === term ? 'PROC' : term.inspect
    case kind
    when :variable
      t
    when :abstraction
      "l[ #{t} ]"
    when :application
      "#{t}[#{Proc === var ? 'PROC' : var.inspect}]"
    end
  end

  # Increment free variables by some ammount `diff`
  def inc_frees(diff, bindings = 0)
    case kind
    when :variable
      term > bindings ? variable(term + diff) : self
    when :abstraction
      lamb?(term) ? abstraction(term.inc_frees(diff, bindings + 1)) : self
    when :application
      t = lamb?(term) ? term.inc_frees(diff, bindings) : term
      v = lamb?(var) ? var.inc_frees(diff, bindings) : var
      application(t, v)
    end
  end

  def reduceable?
    kind == :application && lamb?(term) && (term.kind == :abstraction || term.reduceable?) || Proc === term
  end

  def reduce
    result = one_reduction
    while lamb?(result) && result.reduceable?
      result = result.one_reduction
    end
    if lamb?(result) && Proc === result.term
      puts "NOPE OVER HERE"
      result.term.call(1)
    end
    result
  end

  def one_reduction
    if reduceable?
      if Proc === term
        term.call(var)
      elsif term.kind == :application
        application(term.reduce, var)
      else
        result = term.inc_frees(-1).apply(var, 0)
        if lamb?(result)
          result.kind == :abstraction ? result.term : result
        else
          Proc === result ? result[result] : result
        end
      end
    elsif kind == :application && Proc === term
      puts "HERE I AM"
      term[var]
    else
      puts "not reduceable: #{self.inspect}"
      self
    end
  end

  def apply(arg, level)
    case kind
    when :variable
      if level == term
        arg.respond_to?(:inc_frees) ? arg.inc_frees(level - 1) : arg
      else
        self
      end
      # level == term ? arg.inc_frees(level - 1) : self
    when :abstraction
      if lamb?(term)
        abstraction(term.apply(arg, level + 1))
      elsif Proc === term
        term[arg]
      else
        term
      end
    when :application
      if level.zero?
        r = reduce
        if lamb?(r)
          r.kind == :application ? r : r.apply(arg, level)
        else
          # TODO: Is this right?
          r
        end
      else
        t = lamb?(term) ? term.apply(arg, level) : term
        v = lamb?(var) ? var.apply(arg, level) : var
        # application(t, v).reduce
        application(t, v)
      end
    end
  end

  def ==(other)
    return false unless lamb?(other)
    return false unless kind == other.kind

    case kind
    when :variable, :abstraction
      term == other.term
    when :application
      term == other.term && var == other.var
    end
  end

  # peep :reduce
  # peep :apply
  # peep :inc_frees
end

class Integer
  def [](term)
    LambDeBruijn.application(self, term)
  end
end

l = LambDeBruijn.method(:abstraction)

# Example from https://en.wikipedia.org/wiki/De_Bruijn_index
WIKI = l[ l[ 4[2][l[ 1[3] ]] ] ][l[ 5[1] ]]
WIKI_REDUCED = l[ 3[l[ 6[1] ]][l[ 1[l[ 7[1] ]] ]]]

# Standard Terms
I = l[ 1 ] # I := λx.x
K = l[ l[ 2 ] ] # K := λx.λy.x
S = l[ l[ l[ 3[1][2[1]] ] ] ] # S := λx.λy.λz.x z (y z)
B = l[ l[ l[ 3[2[1]] ] ] ] # B := λx.λy.λz.x (y z)
C = l[ l[ l[ 3[2][1] ] ] ] # C := λx.λy.λz.x z y
W = l[ l[ 2[1][1] ] ] # W := λx.λy.x y y
U = l[ 1[1] ] # U := λx.x x
OMEGA = U[U] # ω := λx.x x and  Ω := ω ω
Y = l[ l[ 2[1[1]] ][l[ 2[1[1]] ]] ] # Y := λg.(λx.g (x x)) (λx.g (x x))

# Some custom terms for testing
CUSTOM = l[ l[ 2 ][1] ]
TEST = 3[1][2[1]]
PARTIAL = l[ l[ 2[1] ] ][l[ 1 ]]

def matches(name, lamb, string)
  return if lamb.inspect == string

  puts "(#{name}) Expected these to be equal:"
  puts '  ' + lamb.inspect
  puts '  ' + string
end

matches('I', I, 'l[ 1 ]')
matches('K', K, 'l[ l[ 2 ] ]')
matches('S', S, 'l[ l[ l[ 3[1][2[1]] ] ] ]')
matches('TEST', TEST, '3[1][2[1]]')
matches('I[I].reduce', I[I].reduce, I.inspect)
matches('I[K].reduce', I[K].reduce, K.inspect)
matches('K[I].reduce', K[I].reduce, 'l[ l[ 1 ] ]')
matches('S[K][K][1].reduce', S[K][K][1].reduce, 'l[ 2 ]')
matches('PARTIAL.reduce', PARTIAL.reduce, 'l[ l[ 1 ][1] ]')
matches('WIKI.reduce', WIKI.reduce, WIKI_REDUCED.inspect)

# Define Numbers

ZERO = l[ l[   1  ] ]
ONE =  l[ l[ 2[1] ] ]

def to_int(lamb)
  counter = 0
  lamb[-> _ { counter += 1; _ }][3].reduce
  counter
end

matches('to_int(ZERO)', to_int(ZERO), '0')
matches('to_int(ONE)', to_int(ONE), '1')

# Define Boleans

T = l[ l[ 2 ] ]
F = l[ l[ 1 ] ]

def to_bool(lamb)
  lamb[true][false].reduce
end

matches('to_bool(T)', to_bool(T), 'true')
matches('to_bool(F)', to_bool(F), 'false')

# Define predicates

IS_ZERO = l[ 1[l[ F ]][T] ]

matches('to_bool(IS_ZERO[ZERO])', to_bool(IS_ZERO[ZERO]), 'true')
matches('to_bool(IS_ZERO[ONE])', to_bool(IS_ZERO[ONE]), 'false')

# Numeric Operations

INCREMENT = l[ l[ l[ 2[3[2][1]] ] ] ]
DECREMENT = l[ l[ l[ 3[l[ l[ 1[2[4]] ] ]][l[ 2 ]][l[ 1 ]] ] ] ]

matches('to_int(INCREMENT[ONE])', to_int(INCREMENT[ONE]), '2')
matches('to_int(DECREMENT[ONE])', to_int(DECREMENT[ONE]), '0')

ADD = l[ l[ 1[INCREMENT][2] ] ]
SUBTRACT = l[ l[ 1[DECREMENT][2] ] ]
MULTIPLY = l[ l[ 1[ADD[2]][ZERO] ] ]
POWER = l[ l[ 1[MULTIPLY[2]][ONE] ] ]

TWO =  l[ l[ 2[2[1]] ] ]
# TWO = INCREMENT[ONE]
THREE = INCREMENT[TWO]
FOUR = POWER[TWO][TWO]
FIVE = INCREMENT[FOUR]
SIX = MULTIPLY[TWO][THREE]
SEVEN = INCREMENT[SIX]
EIGHT = POWER[TWO][THREE]
NINE = POWER[THREE][TWO]
TEN = MULTIPLY[TWO][FIVE]

matches('to_int(TWO)', to_int(TWO), '2')
matches('to_int(THREE)', to_int(THREE), '3')
matches('to_int(FOUR)', to_int(FOUR), '4')
matches('to_int(FIVE)', to_int(FIVE), '5')
matches('to_int(SIX)', to_int(SIX), '6')
matches('to_int(SEVEN)', to_int(SEVEN), '7')
matches('to_int(EIGHT)', to_int(EIGHT), '8')
matches('to_int(NINE)', to_int(NINE), '9')
matches('to_int(TEN)', to_int(TEN), '10')

IS_LESS_OR_EQUAL = l[ l[ IS_ZERO[SUBTRACT[2][1]] ] ]

matches('to_bool(IS_LESS_OR_EQUAL[TEN][NINE])', to_bool(IS_LESS_OR_EQUAL[TEN][NINE]), 'false')
matches('to_bool(IS_LESS_OR_EQUAL[TEN][TEN])', to_bool(IS_LESS_OR_EQUAL[TEN][TEN]), 'true')
matches('to_bool(IS_LESS_OR_EQUAL[TWO][TEN])', to_bool(IS_LESS_OR_EQUAL[TWO][TEN]), 'true')

MOD = Y[l[ l[ l[ IS_LESS_OR_EQUAL[1][2][l[ 4[SUBTRACT[3][2]][2][1] ]][2] ] ] ]]

matches('to_int(MOD[THREE][TWO])', to_int(MOD[THREE][TWO]), '1')

DIV = Y[l[ l[ l[ IS_LESS_OR_EQUAL[1][2][l[ INCREMENT[4[SUBTRACT[3][2]][2]][1] ]][ZERO] ] ] ]]

matches('to_int(DIV[TEN][TWO])', to_int(DIV[TEN][TWO]), '5')

# class LambDeBruijn
#   peep :reduce
#   peep :one_reduction
#   peep :apply
# end
