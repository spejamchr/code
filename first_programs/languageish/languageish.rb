Letters = {
  a: %i{b c d f g h i j k l m n p q r s t u v w x y z},
  b: %i{a e i l o r u y},
  c: %i{a e h i k l n o q r s t u y},
  d: %i{a e g i l o r u y},
  e: %i{a b c d f g h i j k l m n p q r s t u v w x y z},
  f: %i{a e i l o r u y},
  g: %i{a e i l o r u y},
  h: %i{a e i o u y},
  i: %i{a b c d e f g j l m n o p q r s t v x z},
  j: %i{a e i o u},
  k: %i{a e i l m o r u y},
  l: %i{a b c d e f g i k m o p r s t u v w y},
  m: %i{a b e i o p r s t u y},
  n: %i{a d e g i k o s t u x y},
  o: %i{a b c d e f g h i j l m n p q r s t u v w x y z},
  p: %i{a e h i l n o q r s u y},
  q: %i{u},
  r: %i{a c d e f g i j k l m n o u y},
  s: %i{a c e h i k l m n o p q t u y},
  t: %i{a e h i o r u y},
  u: %i{a b c d e f g h i l m n o p r s t v w x z},
  v: %i{a e i l o u y},
  w: %i{a e h i o r u y},
  x: %i{a c e i o u},
  y: %i{a e i m o u x},
  z: %i{a e i o u},
}

Frequencies = { # out of 100,000
  a: 11602, # a
  b: 4702, # b
  c: 3511, # c
  d: 2670, # d
  e: 2007, # e
  f: 3779, # f
  g: 1950, # g
  h: 7232, # h
  i: 6286, # i
  j: 597, # j
  k: 590, # k
  l: 2705, # l
  m: 4383, # m
  n: 2365, # n
  o: 6264, # o
  p: 2545, # p
  q: 173, # q
  r: 1653, # r
  s: 7755, # s
  t: 16671, # t
  u: 1487, # u
  v: 649, # v
  w: 6753, # w
  x: 17, # x
  y: 1620, # y
  z: 34, # z
}

Alphabet = %i{ a b c d e f g j i j k l m n o p q r s t u v w x y z }

def rand_english_letter(letters = Alphabet)
  frequencies = letters.map { |l| Frequencies[l] }
  sum = frequencies.inject(:+)

  num = rand sum
  running_sum = frequencies.first
  index = 0
  while num > running_sum
    index += 1
    running_sum += frequencies[index]
  end
  letters[index].to_s
end

def has_no_vowels(word)
  (word.split('') & %w(a e i o u y)).count == 0
end

def word
  word = rand_english_letter
  lowest_length = ( rand(1..2) * rand(1..3) + rand(1..3) + rand(1..5) )
  while word.length < lowest_length || has_no_vowels(word)
    letters = Letters[word[-1].to_sym]
    if word[-2]
      letters = letters - (Alphabet - Letters[word[-2].to_sym])
      if letters.length == 0
        letters = Letters[word[-1].to_sym]
      end
    end
    word << rand_english_letter(letters)
  end
  word
end

def sentence
  number = rand(10)+10
  sentence = []
  number.times{sentence<<word}
  sentence = sentence.join(' ')
  sentence << '.'
  sentence.capitalize
end

def paragraph
  number = rand(5)+5
  par = ["\t"]
  number.times{par<<sentence}
  par = par.join(' ')
  par<<"\n"
end

puts
4.times {puts paragraph}
puts
