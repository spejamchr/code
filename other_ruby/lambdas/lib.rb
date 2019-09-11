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
