module SG

  class Game
    def initialize
      @board = Board.new
    end

    def play
      start = Time.now
      i = 0
      puts @board.to_s
      while @board.playing?
        case gets.chomp
        when "\e[A"
          @board.north
        when "\e[B"
          @board.south
        when "\e[C"
          @board.east
        when "\e[D"
          @board.west
        else
          puts "Invalid direction; use arrow keys"
          redo
        end
        puts @board.to_s
      end
      puts "You won!"
    end
  end

  class Board
    HEIGHT = 4
    WIDTH = 4

    EMPTY = 0

    # Drawing Characters
    EW = '══'
    NS = '║ '
    NW = '╔═'
    NE = '╗ '
    SW = '╚═'
    SE = '╝ '

    MAPPINGS = {
      0 => '  ',
      1 => 'o ',
      2 => '↑ ',
      3 => '↓ ',
      4 => '→ ',
      5 => '←─',

      6 => '──',
      7 => '│ ',
      8 => '┌─',
      9 => '┐ ',
      10 => '└─',
      11 => '┘ ',
    }

    def self.clean_board
      HEIGHT.times.map { WIDTH.times.map { EMPTY } }
    end

    def initialize
      @board = self.class.clean_board
      @snake = Snake.new(HEIGHT, WIDTH, board: self)
      new_food
    end

    def new_food
      @food = rand_food
      @snake.food = @food
    end

    # TODO: Improve algorithm for the endgame
    def rand_food
      rf = [rand(HEIGHT), rand(WIDTH)]
      while @snake.indices.include?(rf) && playing?
        rf = [rand(HEIGHT), rand(WIDTH)]
      end
      rf
    end

    def playing?
      @snake.indices.count != (HEIGHT * WIDTH)
    end

    def north
      @snake.move(Snake::N)
    end

    def south
      @snake.move(Snake::S)
    end

    def east
      @snake.move(Snake::E)
    end

    def west
      @snake.move(Snake::W)
    end

    def to_s
      @board = self.class.clean_board
      place_food
      place_snake(@snake)

      s = ''
      s += NW
      s += EW * WIDTH
      s += NE
      s += "\n"
      @board.each do |row|
        s += NS + row_string(row) + NS + "\n"
      end
      s += SW
      s += EW * WIDTH
      s += SE
    end

    private

    def row_string(row)
      row.map { |c| char_string(c) }.join
    end

    def char_string(c)
      s = MAPPINGS[c]
      raise "Unrecognized character: `#{c}'" if s.nil?
      s
    end

    def place_snake(snake, ahead=nil)
      h = snake.head
      @board[h[0]][h[1]] = snake.dircode(ahead)
      place_snake(snake.next, snake.dir) unless snake.next.nil?
    end

    def place_food
      @board[@food[0]][@food[1]] = 1
    end
  end

  class Snake
    N = [-1, 0]
    S = [1, 0]
    E = [0, 1]
    W = [0, -1]

    attr_accessor :food, :head, :dir, :next

    def initialize(h, w, board: nil)
      @h = h
      @w = w
      @board = board

      @head = [h/2, w/2]
      @dir = N
      @next = nil
    end

    def move(dir=nil)
      dir ||= @dir
      new_head = @head.zip(dir).map(&:sum)
      if new_head == @food
        new_next = Snake.new(@h, @w)
        new_next.head = @head
        new_next.dir = @dir
        new_next.next = @next
        @next = new_next
        @head = new_head
        puts indices.inspect
        @board.new_food
        @dir = dir
        return
      end
      @head = new_head

      unless (0...@h) === @head[0] && (0...@w) === @head[1]
        raise "Snake ran into the wall!"
      end

      @next&.move(@dir)
      @dir = dir

      unless indices == indices.uniq
        raise "Snake ran into itself!"
      end
    end

    def dircode(a=nil)
      if a.nil?
        return {
          N => 2,
          S => 3,
          E => 4,
          W => 5,
        }[@dir]
      end
      d = @dir
      if a == N && d == S ||
          a == S && d == N ||
          a == E && d == W ||
          a == W && d == E
        raise "Snake ran into itself!"
      end

      r = {
        [N, N] => 7,
        [N, E] => 8,
        [N, W] => 9,
        [S, S] => 7,
        [S, E] => 10,
        [S, W] => 11,
        [E, E] => 6,
        [E, N] => 11,
        [E, S] => 9,
        [W, W] => 6,
        [W, N] => 10,
        [W, S] => 8,
      }[[d, a]]
      raise "Unkown dircode for dir: #{d} and ahead: #{a}" if r.nil?
      r
    end

    def indices
      return [@head] if @next.nil?
      [@head] + @next.indices
    end
  end
end

SG::Game.new.play
