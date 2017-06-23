def other_side? cell1, cell2
  (cell1 == cell1.upcase && cell2 == cell2.downcase) ||
  (cell1 == cell1.downcase && cell2 == cell2.upcase)
end

def side cell
  if cell.downcase == cell
    :w
  else
    :b
  end
end

class Board
  def initialize
    @row_1 = [:c,:h,:b,:q,:k,:b,:h,:c]
    @row_8 = @row_1.map{|i| i.to_s.upcase.to_sym}
    @row_2 = [:p,:p,:p,:p,:p,:p,:p,:p]
    @row_7 = @row_2.map{|i| i.to_s.upcase.to_sym}
    @row_3 = [' ',' ',' ',' ',' ',' ',' ',' ',]
    @row_4 = [' ',' ',' ',' ',' ',' ',' ',' ',]
    @row_5 = [' ',' ',' ',' ',' ',' ',' ',' ',]
    @row_6 = [' ',' ',' ',' ',' ',' ',' ',' ',]
    @rows=[@row_1, @row_2, @row_3, @row_4, @row_5, @row_6, @row_7, @row_8]
  end
  
  def show
    width = 48
    width.times{print'_'}; puts
    print '|  |  A  | B |  C  | D |  E  | F |  G  | H ||  |'; puts
    width.times{print'—'}; puts
    
    (0..7).each do |row|
      colors = (row % 2 == 0 ? [:w, :b] : [:b, :w])
      top_side = '|‾‾|'
      mid_side = "| #{8-row}|"
      bot_side = '|__|'
      
      print top_side
      (0..3).each do |i|
        print Cell.new(colors[0]).top.join
        print Cell.new(colors[1]).top.join
      end
      print "#{top_side}\n#{mid_side}"
      (0..3).each do |i|
        if (@rows.reverse[row][2*i  ]).downcase == @rows.reverse[row][2*i  ]
          side1 = :w
        else
          side1 = :b
        end
        if @rows.reverse[row][2*i+1].to_s.downcase == @rows.reverse[row][2*i+1].to_s
          side2 = :w
        else
          side2 = :b
        end
        print Cell.new(colors[0],@rows.reverse[row][2*i  ],side1).middle.join
        print Cell.new(colors[1],@rows.reverse[row][2*i+1],side2).middle.join
      end
      print "#{mid_side}\n#{bot_side}"
      (0..3).each do |i|
        print Cell.new(colors[0]).bottom.join
        print Cell.new(colors[1]).bottom.join
      end
      puts bot_side
    end
    
    def move(column1,row1,column2,row2,turn)
      cols = {a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8}
      col1 = cols[column1.downcase.to_sym]
      col2 = cols[column2.downcase.to_sym]
      cell1 = @rows[row1-1][col1-1]
      cell2 = @rows[row2-1][col2-1]
      if cell1 == ' '
        puts 'You can\'t move nothing!'
        :error
      elsif cell2 == ' ' || other_side?(cell1, cell2)
        if side(cell1) == turn
          @rows[row2-1][col2-1] = cell1
          @rows[row1-1][col1-1] = ' '
          self.show
          if turn == :w
            puts "Black's turn"
          else
            puts "White's turn"
          end
          :success
        else
          puts 'it\'s not your turn!'
          :error
        end
      else
        puts 'illegal move'
        :error
      end
    end
    
    width.times{print '—'}; puts
    print '|  || A |  B  | C |  D  | E |  F  | G |  H  |  |'; puts
    width.times{print '‾'}; puts
  end
end

class Cell
  def initialize(color,piece=' ',side=nil)
    if color == :w
      @top    = ['     ']
      if side == :b
        @middle = [' |',piece,'| ']
      else
        @middle = ['  ',piece,'  ']
      end
      @bottom = ['     ']
    elsif color == :b
      @top    = ['|‾‾‾|']
      if side == :b
        @middle = ['||',piece,'||']
      else
        @middle = ['| ',piece,' |']
      end
      @bottom = ['|___|']
    end
  end
  
  def top
    @top
  end
  def middle
    @middle
  end
  def bottom
    @bottom
  end
  
  def piece
    @middle[1]
  end
  
  def is_now(piece)
    @middle[1] = piece
  end
  
  def show
    puts [@top,@middle.join,@bottom]
  end
  
  # def other_side? cell
  #   (self.piece == self.piece.upcase && cell.piece == cell.piece.downcase) ||
  #   (self.piece == self.piece.downcase && cell.piece == cell.piece.upcase)
  # end
end



board = Board.new
board.show
puts 'Start the game, White!'
turn = :w
while true
  move = gets.chomp
  col1 = move[0].to_s
  row1 = move[1].to_i
  col2 = move[-2].to_s
  row2 = move[-1].to_i
  if ['a','b','c','d','e','f','g','h'].include?(col1) & ['a','b','c','d','e','f','g','h'].include?(col2) & [1,2,3,4,5,6,7,8].include?(row1) & [1,2,3,4,5,6,7,8].include?(row2)
    if board.move(col1,row1,col2,row2,turn) == :success
      if turn == :w
        turn = :b
      else
        turn = :w
      end
    end
  else
    puts 'illegal instructions. Instructions should be of the form "H2H3"'
  end
end

