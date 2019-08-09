# How can you hang a picture with string on n hooks such that removing just one
# hook will make the picture fall?

class Knot # Sequence: array of non-zero integers representing loops around hooks:
  #   - The absolute value represents which hook is being looped
  #   - The sign (+/-) represents the direction of looping
  def initialize(sequence)
    raise 'Cannot be empty' if sequence.empty?
    raise 'Cannot contain 0' if sequence.any?(&:zero?)
    raise 'Must only contain integers' if sequence.any? { |n| n != n.to_i }

    @sequence = sequence.map(&:to_i)
    @hooks = sequence.map(&:abs).uniq.count
    @reduced_cache = {}
  end

  def solution?
    hangs? & sequence.map(&:abs).uniq.sort.all? { |i| falls?(i) }
  end

  def hangs?(hook=0)
    !falls?(hook)
  end

  def falls?(hook=0)
    reduced(hook).empty?
  end

  def reduced(hook)
    hook = hook.abs
    return reduced_cache[hook] if reduced_cache[hook]

    reduced_cache[hook] = reduce(sequence.filter { |n| n.abs != hook })
  end

  def standardized
    swaps = sequence.map(&:abs).uniq.zip((1..hooks).reverse_each).to_h
    signs = sequence.group_by(&:abs).transform_values { |g| g[0] / g[0].abs }

    sequence.each_with_object([]) do |v, a|
      sign = signs[v.abs] * v / v.abs
      a << (swaps[v.abs] * sign)
    end
  end

  private

  attr_reader :sequence, :hooks, :reduced_cache

  def reduce(tmp_sequence)
    mut_seq = tmp_sequence.dup
    continue = true

    while continue
      i = 0
      deletions = []

      while i + 1 < mut_seq.length
        if (mut_seq[i] + mut_seq[i + 1]).zero?
          deletions += [i, i + 1]
          i += 2
        else
          i += 1
        end
      end

      if deletions.empty?
        continue = false
      else
        deletions.sort.reverse.each { |n| mut_seq.delete_at(n) }
      end
    end

    mut_seq
  end

end

if ARGV[0] == 'test'
  @test_count = 0
  def test(seq, behavior)
    @test_count += 1
    if yield seq
      print '.'
    else
      puts "\033[31mFailed: #{seq} #{behavior}\033[0m"
    end
  end

  def falls(seq, i=0)
    knot = Knot.new(seq)
    test(seq, "falls(#{i}) left #{knot.reduced(i)}") { |s| knot.falls?(i) }
  end

  def hangs(seq, i=0)
    test(seq, "hangs(#{i})") { |s| Knot.new(s).hangs?(i) }
  end

  def raises?
    yield
    false
  rescue
    true
  end

  def raises(seq)
    test(seq, 'raises error') { |s| raises? { Knot.new(s) } }
  end

  def solution(seq)
    hangs(seq)
    seq.map(&:abs).sort.uniq.each { |i| falls(seq, i) }
  end

  def next_sol(seq)
    next_n = (seq.max) + 1
    seq + [next_n] + seq.map(&:-@).reverse + (seq.empty? ? [] : [-next_n])
  end

  def classic_len(n)
    if n < 1
      0
    elsif n == 1
      1
    else
      2 + 2 * classic_len(n - 1)
    end
  end

  COMPRESSED_SOLS = [[1]]
  def compressed_sol(n, offset=0)
    cached = COMPRESSED_SOLS[n-1]
    if cached
      return cached.map { |n| n + offset*(n/n.abs) }
    else
      half = n / 2
      min, max = [half, n - half].sort
      c1 = compressed_sol(max, offset)
      c2 = compressed_sol(min, max + offset)
      COMPRESSED_SOLS[n-1] = c1 + c2 + c1.reverse.map(&:-@) + c2.reverse.map(&:-@)
    end
  end

  def compressed_len(n)
    log2 = Math.log2(n)
    raise 'cannot do that...' unless log2 == log2.to_i

    (4**log2).to_i
  end

  start = Time.now

  a = [1]
  (1..5).each do |n|
    solution(a) if n < 11 && a
    puts "sol_#{n} has #{a.count} elems" if a
    puts "predicted length: #{classic_len(n)}"
    c = compressed_sol(n)
    solution(c)
    puts "\ncomp_sol_#{n} has #{c.count} elems (ratio: #{c.count / n.to_f})\n\n"
    n < 17 ?  a = next_sol(a) : a = nil
  end

  puts "COMPRESSED_SOLS.count: #{COMPRESSED_SOLS.count}"
  puts "COMPRESSED_SOLS[4]: #{COMPRESSED_SOLS[4]}"

  raises([])
  raises([0])
  raises([1.1])
  raises(['a'])
  raises([[1]])

  hangs([1])
  hangs([1, 1])
  hangs([1, 2, -1])
  falls([1, 2, -1], 2)

  solution([1, 2, -1, -2])
  solution([1, 2, -1, -2, 3, 2, 1, -2, -1, -3])
  solution([1, 2, -1, -2, 3, 2, 1, -2, -1, -3, 4, 3, 1, 2, -1, -2, -3, 2, 1, -2, -1, -4])
  solution([1, 2, 3, -2, -1, 2, 1, -3, -1, -2])
  solution([1, 2, -1, -2, 3, 4, -3, -4, 2, 1, -2, -1, 4, 3, -4, -3])

  puts "\nRan #{@test_count} tests in #{Time.now - start}s"
end
