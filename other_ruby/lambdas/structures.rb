load './lib.rb'

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

# Numbers

ZERO = l[ l[   1  ] ]
ONE =  l[ l[ 2[1] ] ]

# Numeric Operations

INCREMENT = l[ l[ l[ 2[3[2][1]] ] ] ]
DECREMENT = l[ l[ l[ 3[l[ l[ 1[2[4]] ] ]][l[ 2 ]][l[ 1 ]] ] ] ]

ADD = l[ l[ 1[INCREMENT][2] ] ]
SUBTRACT = l[ l[ 1[DECREMENT][2] ] ]
MULTIPLY = l[ l[ 1[ADD[2]][ZERO] ] ]
POWER = l[ l[ 1[MULTIPLY[2]][ONE] ] ]

# Booleans

T = l[ l[ 2 ] ]
F = l[ l[ 1 ] ]

NOT = l[ l[ l[ 3[1][2] ] ] ]
AND = l[ l[ 2[1][2] ] ]
OR = l[ l[ 2[2][1] ] ]

# Predicates

IS_ZERO = l[ 1[l[ F ]][T] ]
IS_LESS_OR_EQUAL = l[ l[ IS_ZERO[SUBTRACT[2][1]] ] ]
IS_EQUAL = l[ l[ AND[IS_LESS_OR_EQUAL[2][1]][IS_LESS_OR_EQUAL[1][2]] ] ]


TWO =  l[ l[ 2[2[1]] ] ]
# TWO = INCREMENT[ONE]
THREE = INCREMENT[TWO]
FOUR = POWER[TWO][TWO]
FIVE = INCREMENT[FOUR]
SIX = MULTIPLY[TWO][THREE]
SEVEN = INCREMENT[SIX]
EIGHT = POWER[TWO][THREE]
NINE = POWER[THREE][TWO]
TEN = INCREMENT[MULTIPLY[THREE][THREE]]

# Some recursive stuff

MOD = Y[l[ l[ l[ IS_LESS_OR_EQUAL[1][2][l[ 4[SUBTRACT[3][2]][2][1] ]][2] ] ] ]]
DIV = Y[l[ l[ l[ IS_LESS_OR_EQUAL[1][2][l[ INCREMENT[4[SUBTRACT[3][2]][2]][1] ]][ZERO] ] ] ]]

# class LambDeBruijn
#   peep :reduce
#   peep :one_reduction
#   peep :apply
# end

# Pairs

PAIR = l[ l[ l[ 1[3][2] ] ] ]
FIRST = l[ 1[l[ l[ 2 ] ]] ]
SECOND = l[ 1[l[ l[ 1 ] ]] ]

# Lists

NULL = l[ l[ 1 ] ]
CONS = l[ l[ l[ l[ 2[4][3[2][1]] ] ] ] ]
IS_NULL = l[ 1[l[ l[ F ]]][T] ]
HEAD = l[ 1[l[ l[ 2 ] ]][NULL] ]
TAIL = l[ FIRST[1[l[ l[ PAIR[SECOND[1]][CONS[2][SECOND[1]]] ] ]][PAIR[NULL][NULL]]] ]

FOLD_LEFT = Y[l[ l[ l[ l[ IS_NULL[1][2][l[ 5[4][4[HEAD[2]][3]][TAIL[2]][1] ]] ] ] ] ]]
FOLD_RIGHT = l[ l[ l[ 1[3][2] ] ] ]
MAP = l[ FOLD_RIGHT[l[ CONS[2[1]] ]][NULL] ]

RANGE = Y[l[ l[ l[ IS_LESS_OR_EQUAL[2][1][l[ CONS[3][4[INCREMENT[3]][2]][1] ]][NULL] ] ] ]]
SUM = FOLD_LEFT[ADD][ZERO]
PRODUCT = FOLD_LEFT[MULTIPLY][ONE]
APPEND = l[ l[ FOLD_RIGHT[CONS][1][2] ] ]
PUSH = l[ l[ APPEND[1][CONS[2][NULL]] ] ]
REVERSE = FOLD_RIGHT[PUSH][NULL]

INCREMENT_ALL = MAP[INCREMENT]
DOUBLE_ALL = MAP[MULTIPLY[TWO]]

# Natural numbers with lists

RADIX = TEN
TO_DIGITS = Y[l[ l[ PUSH[MOD[1][RADIX]][IS_LESS_OR_EQUAL[1][DECREMENT[RADIX]]][NULL][l[ 3[DIV[2][RADIX]][1] ]] ] ]]
TO_CHAR = I # assume string encoding where 0 encodes '0', 1 encodes '1' etc
TO_STRING = l[ MAP[TO_CHAR][TO_DIGITS[1]] ]

# FizzBuzz

FIFTEEN = MULTIPLY[THREE][FIVE]
FIZZ = MAP[ADD[RADIX]][CONS[ONE][CONS[TWO][CONS[FOUR][CONS[FOUR][NULL]]]]]
BUZZ = MAP[ADD[RADIX]][CONS[ZERO][CONS[THREE][CONS[FOUR][CONS[FOUR][NULL]]]]]

FIZZBUZZ =
  l[ MAP[l[ IS_ZERO[MOD[1][FIFTEEN]][
    APPEND[FIZZ][BUZZ]
  ][IS_ZERO[MOD[1][THREE]][
    FIZZ
  ][IS_ZERO[MOD[1][FIVE]][
    BUZZ
  ][
    TO_STRING[1]
  ]]]
]][RANGE[ONE][1]] ]

# This evaluates faster than any other form of 100
HUNDRED = l[ l[ 2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[1]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]] ] ]

# puts FIZZBUZZ[ONE].inspect
