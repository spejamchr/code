# a variable, 1, is itself a valid lambda term
# if t is a lambda term, then l[ t ] is a lambda term (called a lambda abstraction);
# if t and s are lambda terms, then t[s] is a lambda term (called an application).

module LogAround
  def peep(method)
    ali = "_orig_#{method}".to_sym
    alias_method ali, method

    define_method(method) do |*args|
      id = (rand*36**4).to_i.to_s(36)
      puts "[#{id}] Calling #{method} with args #{args.inspect} on #{inspect}"

      result = send(ali, *args)

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
      accepts(Integer, var)
      new({ kind: :variable, term: var })
    end

    def abstraction(term)
      new({ kind: :abstraction, term: wrap(term) })
    end

    def application(term, var)
      new({ kind: :application, term: wrap(term), var: wrap(var) })
    end

    def accepts(klass, var)
      raise "Expected #{klass} but got #{var.class}: #{var}" unless klass === var
    end

    def wrap(term, klass = nil)
      klass ||= self
      term = klass.variable(term) if Integer === term
      accepts(klass, term)
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

  def inspect
    case kind
    when :variable
      term.to_s
    when :abstraction
      "l[ #{term.inspect} ]"
    when :application
      "#{term.inspect}[#{var.inspect}]"
    end
  end

  def reduceable?
    kind == :application && (term.kind == :abstraction || term.reduceable?)
  end

  def reduce
    if reduceable?
      result = term.inc_frees(-1).apply(var, 0)
      result.kind == :abstraction ? result.term : result
    else
      self
    end
  end

  # Increment free variables by some ammount `diff`
  def inc_frees(diff, bindings = 0)
    case kind
    when :variable
      term > bindings ? variable(term + diff) : self
    when :abstraction
      abstraction(term.inc_frees(diff, bindings + 1))
    when :application
      application(term.inc_frees(diff, bindings), var.inc_frees(diff, bindings))
    end
  end

  def apply(arg, level)
    case kind
    when :variable
      level == term ? arg.inc_frees(level - 1) : self
    when :abstraction
      abstraction(term.apply(arg, level + 1))
    when :application
      if level.zero?
        r = reduce
        r.kind == :application ? r : r.apply(arg, level)
      else
        application(term.apply(arg, level), var.apply(arg, level)).reduce
      end
    end
  end

  # peep :reduce
  # peep :apply
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
matches('PARTIAL.reduce', PARTIAL.reduce, I.inspect)
matches('WIKI.reduce', WIKI.reduce, WIKI_REDUCED.inspect)

# Define Numbers

ZERO = l[ l[   1  ] ]
ONE =  l[ l[ 2[1] ] ]
