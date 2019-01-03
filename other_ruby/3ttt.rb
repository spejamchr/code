# Play a game of 3-way Tic Tac Toe
#
# Once a board has a 3-in-a-row it is dead.
# Whoever completes 3-in-a-row on the last board loses.
# Both players use the same symbol (X in this case).

module TTT

  # Make it easy to catch all errors raised by this module
  class TTTError < StandardError; end

  # Raised when a user plays outside the board, or on an occupied space
  class InvalidMove < TTTError; end

  # Raised when a user plays on a board that doesn't exist
  class InvalidBoard < TTTError; end

  class Board

    def initialize(rows: 3, cols: 3)
      @rows = rows
      @cols = cols

      @board = all_rows.map { all_cols.map { false } }
    end

    def play(x, y)
      check_valid_move(x, y)

      set(x, y, true)
    end

    def completed?
      horizontal? || vertical? || diagonal?
    end

    def to_s(title: nil)
      y_label = 'Y '
      axis_label_width = 2
      empty_sym = completed? ? '-' : ' '

      row_strings = all_rows.map do |y|
        s = ''
        if y == @rows / 2
          s += y_label
        else
          s += ' ' * y_label.length
        end

        s += y.to_s.ljust(axis_label_width) + ' '
        s += all_cols.map { |x| " #{get(x, y) ? 'X' : empty_sym} " }.join('|')

        s
      end

      inter_rows = ''
      inter_rows += ' ' * y_label.length
      inter_rows += ' ' * axis_label_width
      inter_rows += ' ' + all_cols.map { '---' }.join('+')

      with_y_labels = row_strings.join("\n" + inter_rows + "\n")

      blank_line = ' ' * inter_rows.length

      x_labels = ''
      x_labels += ' ' * y_label.length
      x_labels += ' ' * axis_label_width
      x_labels += ' ' + all_cols.map { |x| x.to_s.center(3) }.join(' ')

      x_title = ''
      x_title += ' ' * y_label.length
      x_title += ' ' * axis_label_width
      x_title += ' ' + all_cols.map { |x| (x == @cols / 2 ? 'X' : '').center(3) }.join(' ')

      pieces = [with_y_labels, blank_line, x_labels, x_title]
      if title
        pieces = [title.center(x_title.length), blank_line] + pieces
      end
      pieces.join("\n")
    end

    private

    def get(x, y)
      @board[y][x]
    end

    def set(x, y, val)
      @board[y][x] = !!val
    end

    def check_valid_move(x, y)
      if !all_rows.include?(y) || !all_cols.include?(x)
        raise InvalidMove, 'Move is outside of board'
      elsif get(x, y)
        raise InvalidMove, 'Move has already been played'
      end
    end

    def horizontal?
      all_rows.any? { |y| all_cols.all? { |x| get(x, y) } }
    end

    def vertical?
      all_cols.any? { |x| all_rows.all? { |y| get(x, y) } }
    end

    def diagonal?
      return false unless @rows == @cols
      all_cols.all? { |n| get(n, n) } ||
        all_cols.zip(all_cols.reverse_each).all? { |x, y| get(x, y) }
    end

    def all_rows
      (0..@rows-1)
    end

    def all_cols
      (0..@cols-1)
    end

  end

  class System

    def initialize(boards: 3, rows: 3, cols: 3)
      @boards = boards.times.map { Board.new(rows: rows, cols: cols) }
    end

    def play(board, x, y)
      check_valid_board(board)
      @boards[board].play(x, y)
    end

    def completed?
      @boards.all?(&:completed?)
    end

    def to_s
      t_cols = ENV['COLUMNS'].to_i
      board_joiner = '  '
      strings = @boards.each_with_index.map { |b, i| b.to_s(title: "Board #{i}") }
      per_row = t_cols / (strings.first.split("\n").first.length + board_joiner.length)
      rows = (strings.count / per_row + 1).times.map do |row|
        row_strings = strings.drop(row * per_row).first(per_row)
        row_string_lines = row_strings.map { |s| s.split("\n") }
        row_string_lines.first
          .zip(*row_string_lines.last(row_string_lines.count - 1))
          .map { |r| r.join(board_joiner) }
          .join("\n")
      end

      "\n" + rows.join("\n\n") + "\n\n"
    end

    private

    def check_valid_board(board)
      if @boards[board].nil?
        raise InvalidBoard, 'Board does not exist'
      elsif @boards[board].completed?
        raise InvalidBoard, 'Board is already complete'
      end
    end

  end

  class Game

    def initialize(boards: 3, rows: 3, cols: 3)
      @system = System.new(boards: boards, rows: rows, cols: cols)
      @turns = 0
    end

    def repl
      until @system.completed?
        puts @system.to_s
        loop do
          board, x, y = read
          begin
            @system.play(board, x, y)
            break
          rescue TTTError => e
            puts e.to_s
            puts "Try again"
          end
        end
        @turns += 1
      end

      puts @system.to_s
      puts "\nPlayer #{player} wins after #{@turns} turns!"
    end

    private

    def player
      ((-1)**(1 + @turns) + 1) / 2
    end

    def read
      loop do
        print "Player #{player}, what is your move? Enter as `Board#, X#, Y#': "
        board, x, y = gets.chomp.scan(/\d+/).map(&:to_i)
        if [board, x, y].any?(&:nil?)
          puts "Please enter three numbers: Board, X, and Y."
        else
          return [board, x, y]
        end
      end
    end

  end
end
