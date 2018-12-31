EXAMPLE = <<-EXAMPLE

# This is a comment!

# (puts (+ 1 2 3 4))
#
# (def add (list a b)
#   (+ a b)
# )
#
# (= var1 2)
# (= var2 7)
#
# (puts (add var1 var2))
#
# (def max_plus_1 (list *b)
#   (+ (max *b) 1)
# )
#
# (puts (max_plus_1 4 9)))
#
# (if (> (= a rand) 0.5)
#   (puts "It's BIGGER!")
#   (puts "It's smaller...")
# )
#
# (puts a)

(def stringify (list a)
  (if (is a String)
    (list a)
    (if (is a Array)
      (+ '[' (list a) ']')
      ()
    )
  )
)

(puts (stringify (list a b c)))

EXAMPLE

def stringify(a)
  return a if a.is_a?(String)
  return '[' + a.map(&:to_s).join(', ') + ']' if a.is_a?(Array)
end

injectibles = [:+, :-, :*, :/]
codes = injectibles.map { |i| -> (*a) { "#{stringify(a)}.inject(:#{i})" } }
hash = Hash[injectibles.zip(codes)]

comparators = ['>', '<', '>=', '<=', '!=', '==']
codes = (comparators.map { |c| -> (a, b) { "#{a} #{c} #{b}" } })
hash = hash.merge(Hash[comparators.zip(codes)])

$defined = {}

BUILTINS = hash.merge(
  is: -> (a, klass) { "#{a}.is_a?(#{klass})" },
  puts: ->(*a) { "puts #{a.join(',')}" },
  list: -> (*a) { a.join(',') },
  def: lambda do |name, args, body|
    $defined[name] = -> (*a) { "#{name}(#{a.join(',')})" }
    "def #{name}#{args}\n  #{body}\nend"
  end,
  max: -> (*a) { "#{stringify a}.max" },
  if: lambda do |cond, t, f|
    "if #{cond}\n  #{t}\nelse\n  #{f}\nend"
  end,
  rand: -> (*a) { a == [] ? 'rand' : "rand(#{a})" },
  '>' => -> (a, b) { "#{a} > #{b}" },
  '<' => -> (a, b) { "#{a} < #{b}" },
  '>=' => -> (a, b) { "#{a} >= #{b}" },
  '<=' => -> (a, b) { "#{a} <= #{b}" },
  '!=' => -> (a, b) { "#{a} != #{b}" },
  :'=' => -> (a, b) { "#{a} = #{b}" }
)

COMMENT = /#.+/
ATOM = /^[\w=\.\+\-]+$/
LIST = /\(.+\)/m

# A list with no literal lists inside
ATOMIC_LIST = /\([^\(\)]+\)/m

# ATOM
#
# Optional + or -, followed by digits, followed by optional . and optionally
# more digits
NUMBER = /^[+-]?\d+\.?\d*$/
# Any atom that's not a valid number
# WORD

# NUMBER
#
INTEGER = /^[+-]?\d+$/
FLOAT = /^[+-]?\d+\.\d+$/

def list_check(list_string)
  fail 'List must begin with `(`' unless list_string[0] == '('
  fail 'List must end with `)`' unless list_string[-1] == ')'
end

def atomic_list?(list_string)
  list_string == list_string[ATOMIC_LIST]
end

def typify(element)
  if NUMBER =~ element
    return element.to_i if INTEGER =~ element
    element.to_f if FLOAT =~ element
  elsif ATOM =~ element
    element.to_sym
  else
    element
  end
end

def elements_from_atomic_list_string(atomic_list_string)
  list_check(atomic_list_string)
  first = atomic_list_string.index(/\S/, 1)
  last = atomic_list_string.rindex(/\S/, -2)
  elements = atomic_list_string[first..last].split(/\s+/)
  elements.map { |e| typify(e) }
end

def elements_from_list_string(list_string)
  list_check(list_string)
  level = 0
  first = i = list_string.index(/\S/, 1)
  elements = []
  until i == list_string.length
    i += 1
    if (/\s/ === list_string[i] || ')' == list_string[i]) && level == 0
      elements << list_string[first...i]
      first = list_string.index(/\S/, i)
      i = first
    end
    level += 1 if list_string[i] == '('
    level -= 1 if list_string[i] == ')'
  end
  elements.map { |e| typify(e) }
end

def list_string?(element)
  element =~ LIST
end

def parse_list_string(list_string)
  list_check(list_string)
  list_string = list_string.gsub(/\s+/, ' ')
  return elements_from_atomic_list_string(list_string) if atomic_list?(list_string)
  elements_from_list_string(list_string).map do |element|
    list_string?(element) ? parse_list_string(element) : element
  end
end

def first_list(string)
  i = string.index('(')
  return '' unless i
  start = i
  depth = 1
  until depth == 0
    i += 1
    depth += 1 if string[i] == '('
    depth -= 1 if string[i] == ')'
  end
  found = string[start..i]
  string[0...i] = ''
  found
end

def parse(code)
  parsed = []
  code = code.gsub(COMMENT, '')
  parsed << parse_list_string(first_list(code)) while code.index('(')
  parsed
end

def find_method(method)
  if BUILTINS[method].nil? && $defined[method].nil?
    fail "Method not found: #{method}"
  end
  return $defined[method] unless $defined[method].nil?
  BUILTINS[method]
end

def codify_array(code_array)
  method = code_array.first
  args = code_array[1..-1] # This is in Tough
  args = args.map { |a| a.is_a?(Array) ? '(' + codify_array(a) + ')' : a }
  find_method(method).call(*args)
end

def codify(code)
  parse(code).map { |pa| codify_array(pa) }.join("\n")
end

code = codify(EXAMPLE)
puts code
puts
eval(code)
