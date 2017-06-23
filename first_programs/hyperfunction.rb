class Integer

  def zero
    self+1
  end

  def one num # self + num
    self + num

    num.times.inject(self) {|mem| mem.zero }
  end

  def two num # self * num
    self * num

    num.times.inject(0) {|mem, n| self + mem }
  end

  def three num # self ** num
    self ** num

    num.times.inject(1) {|mem, n| self * mem }
  end

  def four num
    num.times.inject(1) {|mem, n| self ** mem }
  end

  def five num
    num.times.inject(1) {|mem, n| self.four mem }
  end

  def h(h=0, num=0) # h for hyperfunction
    return self + 1 if h == 0
    return num + self if h == 1
    return num * self if h == 2
    return self ** num if h == 3

    (i = 1) && h <= 2 && (i = 0) && h == 1 && (i = self)

    num.times.inject(i) {|mem, n| h == 1 ? mem.h : self.h(h-1, mem) }
  end
end

hyp = -> (h, a, b) {
  return a + 1 if h == 0
  return b + a if h == 1
  return b * a if h == 2
  return a ** b if h == 3

  (i = 1) && h <= 2 && (i = 0) && h == 1 && (i = a)

  b.times.inject(i) {|mem, n| h == 1 ? hyp.(0, mem, 0) : hyp.(h-1, a, mem) }
}

hp = -> (a, h, b) {
  return a ** b if h == 1
  b.times.inject(1) {|mem, n| hp.(a, h-1, mem) }
}
