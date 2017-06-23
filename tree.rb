class SortedBinaryTree
  attr_accessor :root, :count

  class Node
    attr_accessor :right, :left, :parent, :value

    def initialize(right, left, parent, value)
      @right = right
      @left = left
      @parent = parent
      @value = value
    end

    def internal?
      @right || @left
    end

    def leaf?
      !internal?
    end
  end

  def initialize
    @root = nil
    @count = 0
  end

  def contains?(value)
    value == find_under(@root, value).value
  end

  def <<(value)
    return add_root(value) unless @root
    n = find_under(@root, value)
    if value != n.value
      if value > n.value
        n.right = Node.new(nil, nil, n, value)
      else
        n.left = Node.new(nil, nil, n, value)
      end
      @count += 1
    end
    self
  end

  def >>(value)
    n = find_under(@root, value)
    delete(n) if value == n.value
    self
  end
  #
  # def inspect
  #   puts_node(@root, 0)
  # end

  def inspect
    levels = []
    current_level = []
    current = []
    children = []
    current << @root if @root
    until current.empty?
      working = current.shift
      current_level << working.value
      children << working.left
      children << working.right
      if current.empty?
        levels << current_level
        current_level = []
        current = children
        children = []
      end
    end
    level_count = levels.count
    char_width = 3 # two for a digit, one for a space (eg. "35 ")
    width = 2**(level_count - 1) * char_width
    string = ''
    levels.each_with_index do |level, i|
      level.each do |val|
        string << val.to_s.center(width / 2**i)
      end
      string << "\n  "
    end
    string
  end

  def levels
    height(@root)
  end

  def clear
    @root = nil
  end

  def add_range(min, max)
    return if min > max
    avg = (min + max) / 2
    self << avg
    add_range(min, avg - 1)
    add_range(avg + 1, max)
  end

  private

  def height(n)
    return 1 if n.leaf?
    1 +
      if n.right && n.left
        [height(n.right), height(n.left)].max
      else
        height(n.right ? n.right : n.left)
      end
  end

  def puts_node(n, level)
    puts ' ' * level + n.value.to_s
    puts_node(n.left, level + 1) if n.left
    puts_node(n.right, level + 1) if n.right
  end

  def find_under(n, value)
    if value == n.value
      n
    elsif value > n.value
      n.right ? find_under(n.right, value) : n
    else
      n.left ? find_under(n.left, value) : n
    end
  end

  def add_root(value)
    raise "Root already exists" if @root
    @root = Node.new(nil, nil, nil, value)
    @count = 1
    self
  end

  def delete(n)
    if n.left && n.right
      replacement = rand > 0.5 ? min_under(n.right) : max_under(n.left)
      n.value = replacement.value
      n = replacement
    end

    child = n.left ? n.left : n.right
    child.parent = n.parent if child

    if @root == n
      @root = child
    else
      if n.parent.left == n
        n.parent.left = child
      else
        n.parent.right = child
      end
    end

    # disable n
    n.parent = n
    n.right = n.left = n.value = nil
    @count -= 1
  end

  def max_under(n)
    n.right ? max_under(n.right) : n
  end

  def min_under(n)
    n.left ? min_under(n.left) : n
  end
end
