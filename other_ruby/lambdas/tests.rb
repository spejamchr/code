load './helpers.rb'

# Test the #inspect method
matches('I', I, 'λ 1')
matches('K', K, 'λ λ 2')
matches('S', S, 'λ λ λ 3 1 (2 1)')
matches('TEST', TEST, '3 1 (2 1)')
matches('I[I].reduce', I[I].reduce, I.inspect)
matches('I[K].reduce', I[K].reduce, K.inspect)
matches('K[I].reduce', K[I].reduce, 'λ λ 1')
matches('S[K][K][1].reduce', S[K][K][1].reduce, 'λ 2')
matches('PARTIAL.reduce', PARTIAL.reduce, 'λ λ 1 1')
matches('WIKI.reduce', WIKI.reduce, WIKI_REDUCED.inspect)

matches('to_integer(ZERO)', to_integer(ZERO), '0')
matches('to_integer(ONE)', to_integer(ONE), '1')

matches('to_boolean(T)', to_boolean(T), 'true')
matches('to_boolean(F)', to_boolean(F), 'false')

matches('to_boolean(IS_ZERO[ZERO])', to_boolean(IS_ZERO[ZERO]), 'true')
matches('to_boolean(IS_ZERO[ONE])', to_boolean(IS_ZERO[ONE]), 'false')

matches('to_integer(INCREMENT[ONE])', to_integer(INCREMENT[ONE]), '2')
matches('to_integer(DECREMENT[ONE])', to_integer(DECREMENT[ONE]), '0')

matches('to_integer(TWO)', to_integer(TWO), '2')
matches('to_integer(THREE)', to_integer(THREE), '3')
matches('to_integer(FOUR)', to_integer(FOUR), '4')
matches('to_integer(FIVE)', to_integer(FIVE), '5')
matches('to_integer(SIX)', to_integer(SIX), '6')
matches('to_integer(SEVEN)', to_integer(SEVEN), '7')
matches('to_integer(EIGHT)', to_integer(EIGHT), '8')
matches('to_integer(NINE)', to_integer(NINE), '9')
matches('to_integer(TEN)', to_integer(TEN), '10')

matches('to_boolean(IS_LESS_OR_EQUAL[TEN][NINE])', to_boolean(IS_LESS_OR_EQUAL[TEN][NINE]), 'false')
matches('to_boolean(IS_LESS_OR_EQUAL[TEN][TEN])', to_boolean(IS_LESS_OR_EQUAL[TEN][TEN]), 'true')
matches('to_boolean(IS_LESS_OR_EQUAL[TWO][TEN])', to_boolean(IS_LESS_OR_EQUAL[TWO][TEN]), 'true')

matches('to_integer(MOD[THREE][TWO])', to_integer(MOD[THREE][TWO]), '1')

matches('to_integer(DIV[TEN][TWO])', to_integer(DIV[TEN][TWO]), '5')

matches('to_string(BUZZ)', to_string(BUZZ), '"Buzz"')

start = Time.now
red = SIMPLE_MAP[TWO].reduce
puts "Reducing SIMPLE_MAP took #{Time.now - start}s"

start = Time.now
ar = to_array(red)
puts "to_array took #{Time.now - start}s"

start = Time.now
strings = ar.map { |e| to_string(e) }
puts strings.inspect
puts "to_strings took #{Time.now - start}s"

start = Time.now
fb = FIZZBUZZ[HUNDRED]#.reduce
puts "BEFORE"
puts
puts fb.inspect
puts
puts "AFTER"
puts
fb = fb.reduce
puts fb.inspect
puts
puts "Reducing FizzBuzz took #{Time.now - start}s"

start = Time.now
ar = to_array(fb)
puts "to_array took #{Time.now - start}s"

start = Time.now
strings = ar.map { |e| to_string(e) }
puts strings.inspect
puts "to_strings took #{Time.now - start}s"
