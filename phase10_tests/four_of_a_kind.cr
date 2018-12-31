# Test various strategies for collecting four of a kind in Phase 10
#
# (Simplified, of course. Only consider number cards, not skips or wilds)
#
# - Strategy 1: Always draw from the draw pile (completely random)
# - Strategy 2: Draw from the discard pile if it's a card you already have
#   (unless you would end up discarding it)
# - Strategy 3: Only draw from the discard pile if it completes a set of 3 or 4
#   (unless you would discard it)
# - Strategy 4: Only draw from the discard pile if it completes the set of 4
#
# The winning strategy seems to be Strategy 3, which only slightly beats
# Strategy 2.

def rand_card : Int32
  rand(12) + 1
end

class Hand
  def self.new_hand : Array(Int32)
    10.times.map { rand_card }.to_a
  end

  def initialize
    @cards = Hand.new_hand
  end

  def four_of_a_kind?
    @cards.group_by(&.itself).values.max_by(&.size).size >= 4
  end

  def to_discard
    @cards.group_by(&.itself).values.min_by(&.size).first
  end

  def discard
    card_index = @cards.index(to_discard)
    if card_index
      @cards.delete_at(card_index)
    end
  end

  def strat(n)
    discard_option = rand_card
    if @cards.count { |c| c == discard_option } >= (n-1) && discard_option != to_discard
      @cards << discard_option
    else
      @cards << rand_card
    end

    discard
  end

  def play(strat_n)
    new_hand
    turns = 0
    until(four_of_a_kind?)
      turns += 1
      strat(strat_n)
    end
    turns
  end

  def new_hand
    @cards = Hand.new_hand
  end
end

def test(hand, strat)
  results = 100000.times.map { hand.play(strat) }.to_a
  avg = results.sum.to_f / results.size
  puts "Strategy #{strat} averaged #{avg} turns"
  avg
end

hand = Hand.new

test(hand, 1)
test(hand, 2)
test(hand, 3)
test(hand, 4)
