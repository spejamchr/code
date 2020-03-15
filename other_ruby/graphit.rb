
# Graph functions in the terminal
class Graphit
  require 'io/console'

  # (xa..xb) - x-bounds on which to  graph the functions
  # fns - aray of Procs that when called with Numerics will return Numerics
  def initialize(xa, xb, fns)
    type 'xa', xa, Numeric
    type 'xb', xb, Numeric
    type 'fns', fns, Array
    # type 'fns[]', fns[0], ::MethodSource::MethodExtensions
    fns.each_with_index { |fn, i| type "fn[#{i}][#{xa}]", fn[xa], Numeric }
    raise 'xb must be greater than xa' unless xb > xa

    @fns = fns

    # Columns
    @xa = xa
    @xb = xb

    @rows, @cols = IO.console.winsize.map { |n| n - 5 }
    @display = @rows.times.map { @cols.times.map { +' ' } }

    @values = fns.map { |g| @cols.times.map { |j| g[j_to_x(j)] } }

    # Rows
    @ya = @values.flatten.min
    @yb = @values.flatten.max
  end

  def bounds
    {
      xa: @xa,
      xb: @xb,
      ya: @ya,
      yb: @yb
    }
  end

  def to_s
    @values.zip('A'..).each do |g, l|
      g.each_with_index do |y, j|
        @display.fetch(y_to_i(y)).fetch(j)[0] = l
      end
    end

    [
     '#' * (@cols + 2),
     @display.reverse.map { |r| '#' + r.join + '#' }.join("\n"),
     '#' * (@cols + 2),
    ].join("\n")
  end

  private

  def type(name, thing, klass)
    return if thing.is_a? klass

    raise "Expected #{name} to be a #{klass} but got a #{thing.class}: #{thing}"
  end

  def x_to_j(x)
    raise "Out of bounds: (#{@xa}..#{@xb}), but was #{x}" unless (@xa..@xb).include? x

    (((x - @xa) / (@xb - @xa)) * (@cols - 1)).round
  end

  def y_to_i(y)
    raise "Out of bounds: (#{@ya}..#{@yb}), but was #{y}" unless (@ya..@yb).include? y

    (((y - @ya) / (@yb - @ya)) * (@rows - 1)).round
  end

  def j_to_x(j)
    raise "Out of bounds: (0...#{@cols}), but was #{j}" unless (0...@cols).include? j

    (j / @cols.to_f) * (@xb - @xa) + @xa
  end

  def i_to_y(i)
    raise "Out of bounds: (0...#{@rows}), but was #{i}" unless (0...@rows).include? i

    (i / @rows.to_f) * (@yb - @ya) + @ya
  end
end
