load './lib.rb'

L = LambDeBruijn.method(:abstraction)

# Example from https://en.wikipedia.org/wiki/De_Bruijn_index
WIKI = L[ L[ 4[2][L[ 1[3] ]] ] ][L[ 5[1] ]]
WIKI_REDUCED = L[ 3[L[ 6[1] ]][L[ 1[L[ 7[1] ]] ]]]

# Standard Terms
I = L[ 1 ] # I := λx.x
K = L[ L[ 2 ] ] # K := λx.λy.x
S = L[ L[ L[ 3[1][2[1]] ] ] ] # S := λx.λy.λz.x z (y z)
B = L[ L[ L[ 3[2[1]] ] ] ] # B := λx.λy.λz.x (y z)
C = L[ L[ L[ 3[2][1] ] ] ] # C := λx.λy.λz.x z y
W = L[ L[ 2[1][1] ] ] # W := λx.λy.x y y
U = L[ 1[1] ] # U := λx.x x
OMEGA = U[U] # ω := λx.x x and  Ω := ω ω
Y = L[ L[ 2[1[1]] ][L[ 2[1[1]] ]] ] # Y := λg.(λx.g (x x)) (λx.g (x x))

# Some custom terms for testing
CUSTOM = L[ L[ 2 ][1] ]
TEST = 3[1][2[1]]
PARTIAL = L[ L[ 2[1] ] ][L[ 1 ]]

# Numbers

ZERO = L[ L[   1  ] ]
ONE =  L[ L[ 2[1] ] ]

# Numeric Operations

INCREMENT = L[ L[ L[ 2[3[2][1]] ] ] ]
DECREMENT = L[ L[ L[ 3[L[ L[ 1[2[4]] ] ]][L[ 2 ]][L[ 1 ]] ] ] ]

ADD = L[ L[ 1[INCREMENT][2] ] ]
SUBTRACT = L[ L[ 1[DECREMENT][2] ] ]
MULTIPLY = L[ L[ 1[ADD[2]][ZERO] ] ]
POWER = L[ L[ 1[MULTIPLY[2]][ONE] ] ]

# Booleans

T = L[ L[ 2 ] ]
F = L[ L[ 1 ] ]

NOT = L[ L[ L[ 3[1][2] ] ] ]
AND = L[ L[ 2[1][2] ] ]
OR = L[ L[ 2[2][1] ] ]

# Predicates

IS_ZERO = L[ 1[L[ F ]][T] ]
IS_LESS_OR_EQUAL = L[ L[ IS_ZERO[SUBTRACT[2][1]] ] ]
IS_EQUAL = L[ L[ AND[IS_LESS_OR_EQUAL[2][1]][IS_LESS_OR_EQUAL[1][2]] ] ]


TWO =  L[ L[ 2[2[1]] ] ]
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

MOD = Y[L[ L[ L[ IS_LESS_OR_EQUAL[1][2][3[SUBTRACT[2][1]][1]][2] ] ] ]]

DIV = Y[L[ L[ L[ IS_LESS_OR_EQUAL[1][2][INCREMENT[3[SUBTRACT[2][1]][1]]][ZERO] ] ] ]]

# class LambDeBruijn
#   peep :reduce
#   peep :one_reduction
#   peep :apply
# end

# Pairs

PAIR = L[ L[ L[ 1[3][2] ] ] ]
FIRST = L[ 1[L[ L[ 2 ] ]] ]
SECOND = L[ 1[L[ L[ 1 ] ]] ]

# Lists

NULL = L[ L[ 1 ] ]
CONS = L[ L[ L[ L[ 2[4][3[2][1]] ] ] ] ]
IS_NULL = L[ 1[L[ L[ F ]]][T] ]
HEAD = L[ 1[L[ L[ 2 ] ]][NULL] ]
TAIL = L[ FIRST[1[L[ L[ PAIR[SECOND[1]][CONS[2][SECOND[1]]] ] ]][PAIR[NULL][NULL]]] ]

FOLD_RIGHT = L[ L[ L[ 1[3][2] ] ] ]
MAP = L[ FOLD_RIGHT[L[ CONS[2[1]] ]][NULL] ]

RANGE = Y[L[ L[ L[ IS_LESS_OR_EQUAL[2][1][CONS[2][3[INCREMENT[2]][1]]][NULL] ] ] ]]
APPEND = L[ L[ FOLD_RIGHT[CONS][1][2] ] ]
PUSH = L[ L[ APPEND[1][CONS[2][NULL]] ] ]
REVERSE = FOLD_RIGHT[PUSH][NULL]

INCREMENT_ALL = MAP[INCREMENT]
DOUBLE_ALL = MAP[MULTIPLY[TWO]]

# Natural numbers with lists

RADIX = TEN
TO_DIGITS = Y[    L[     L[ PUSH[MOD[1][RADIX]][   IS_LESS_OR_EQUAL[1][DECREMENT[RADIX]][NULL][2[DIV[1][RADIX]]] ] ]]]
TO_CHAR = I # assume string encoding where 0 encodes '0', 1 encodes '1' etc
TO_STRING = L[ MAP[TO_CHAR][TO_DIGITS[1]] ]

# FizzBuzz

FIFTEEN = MULTIPLY[THREE][FIVE]
FIZZ = MAP[ADD[RADIX]][CONS[ONE][CONS[TWO][CONS[FOUR][CONS[FOUR][NULL]]]]]
BUZZ = MAP[ADD[RADIX]][CONS[ZERO][CONS[THREE][CONS[FOUR][CONS[FOUR][NULL]]]]]

SIMPLE_MAP = L[ MAP[L[ TO_STRING[1] ]][RANGE[ONE][1] ] ]

FIZZBUZZ =
  L[ MAP[L[ IS_ZERO[MOD[1][FIFTEEN]][
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
HUNDRED = L[ L[ 2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[2[1]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]] ] ]

# puts FIZZBUZZ[ONE].inspect
