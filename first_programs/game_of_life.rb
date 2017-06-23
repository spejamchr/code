require "highline/system_extensions.rb"
COLS, ROWS = HighLine::SystemExtensions.terminal_size
LIVING_CELL = '◼'
DEAD_CELL = '◻'
OPEN_BORDERS = false

def fit_pattern_to(height,width,pattern)
  pattern = pattern.map do |row|
    if width >= row.count
      if (width-row.count) % 2 != 0
        add_on = [0]
      end
      row = Array.new((width-row.count)/2).map{0} << row << Array.new((width-row.count)/2).map{0}
      row << add_on if add_on
      row.flatten!
    else
      if (row.count-width) % 2 != 0
        row.pop
      end
      ((row.count-width)/2).times do
        row.pop
        row.shift
      end
      row
    end
  end

  if height >= pattern.count
    if (height-pattern.count) % 2 != 0
      add_on2 = Array.new(width).map{0}
    end
    landscape = []
    array = Array.new((height-pattern.count)/2){ Array.new(width).map{0} }
    array.each {|r| landscape << r }
    pattern.each {|row| landscape << row }
    array = Array.new((height-pattern.count)/2){ Array.new(width).map{0} }
    array.each{|row| landscape<<row}
    landscape << add_on2 if add_on2
    landscape
  else
    if (pattern.count-height) % 2 != 0
      pattern.pop
    end
    ((pattern.count-height)/2).times do
      pattern.pop
      pattern.shift
    end
    pattern
  end
end

def evaluate (row,column,landscape)
  column_max = landscape[0].count
  row_max = landscape.count

  count = 0
  count += 1 if [1,2].include? landscape[row-1][column-1]
  count += 1 if [1,2].include? landscape[row-1][column  ]
  count += 1 if [1,2].include? landscape[row-1][(column+1) % column_max]
  count += 1 if [1,2].include? landscape[row  ][column-1]
  count += 1 if [1,2].include? landscape[row  ][(column+1) % column_max]
  count += 1 if [1,2].include? landscape[(row+1) % row_max][column-1]
  count += 1 if [1,2].include? landscape[(row+1) % row_max][column  ]
  count += 1 if [1,2].include? landscape[(row+1) % row_max][(column+1) % column_max]
  #
  # count += 1 if [1,2].include? landscape[row-2][column-2]
  # count += 1 if [1,2].include? landscape[row-2][column  ]
  # count += 1 if [1,2].include? landscape[row-2][(column+2) % column_max]
  # count += 1 if [1,2].include? landscape[row  ][column-2]
  # count += 1 if [1,2].include? landscape[row  ][(column+2) % column_max]
  # count += 1 if [1,2].include? landscape[(row+2) % row_max][column-2]
  # count += 1 if [1,2].include? landscape[(row+2) % row_max][column  ]
  # count += 1 if [1,2].include? landscape[(row+2) % row_max][(column+2) % column_max]
  #
  # count += 1 if [1,2].include? landscape[row-2][column-1]
  # count += 1 if [1,2].include? landscape[row-2][(column+1) % column_max]
  # count += 1 if [1,2].include? landscape[(row+2) % row_max][column-1]
  # count += 1 if [1,2].include? landscape[(row+2) % row_max][(column+1) % column_max]
  #
  # count += 1 if [1,2].include? landscape[row-1][column-2]
  # count += 1 if [1,2].include? landscape[row-1][(column+2) % column_max]
  # count += 1 if [1,2].include? landscape[(row+1) % row_max][column-2]
  # count += 1 if [1,2].include? landscape[(row+1) % row_max][(column+2) % column_max]

  cell = landscape[row][column]
  # intermmediate values: 2=will die, 3= will begin to live, 1=will continue living
  if cell == 1
    if count < 2
      landscape[row][column] = 2
    elsif count > 3
      landscape[row][column] = 2
    end
  elsif cell == 0
    if count == 3
      landscape[row][column] = 3
    end
  end
end


  def ev(landscape)
    landscape.each_with_index do |row,ri|
      row.each_with_index do |column,ci|
        if OPEN_BORDERS
          evaluate(ri,ci,landscape)
        else
          evaluate(ri,ci,landscape) unless [ci,ri].include?(0)
        end
      end
    end
  end

def clean(landscape)
  landscape.each_with_index do |row,ri|
    row.each_with_index do |column,ci|
      if landscape[ri][ci] == 1 || landscape[ri][ci] == 3
        landscape[ri][ci] = 1
      else
        landscape[ri][ci] = 0
      end
    end
  end
end

def play_game(landscape)
  saved = (Array.new << landscape)[0]
  landscape = fit_pattern_to(ROWS-8,COLS,landscape)
  start        = Time.new
  keep_going   = true
  generation   = 0
  rand_checker = rand(1..10)
  old_land     = (Array.new << landscape).flatten
  max_population = 0
  while keep_going
    if Time.new - start > 0.1
      generation += 1
      if generation % rand_checker == 0
        if landscape.flatten == old_land
          landscape = saved
          generation = 1
          max_population = 0
        end
        old_land = (Array.new << landscape).flatten
        rand_checker = rand(1..10)
      end
      cols, rows = HighLine::SystemExtensions.terminal_size
      landscape = fit_pattern_to(rows-8,cols,landscape)
      puts "\e[H\e[2J"
      (0...landscape.count).each {|row| puts landscape[row].map{|i| i == 0 ? i = DEAD_CELL : i.nil? ? i = DEAD_CELL : i = LIVING_CELL}.join+"\n"}
      population = landscape.flatten.compact.inject(:+)
      max_population = population if population > max_population
      puts
      puts "Gen: #{generation}\n\nPop: #{population}\n\nMax Pop: #{max_population}"
      ev(landscape)
      clean(landscape)
      start = Time.new
    end
  end
  # landscape = landscape.map{|row| row.map{|entry| entry = 0}}
  # landscape[landscape.count/2-1][landscape[0].count/2-3]='G'
  # landscape[landscape.count/2-1][landscape[0].count/2-2]='A'
  # landscape[landscape.count/2-1][landscape[0].count/2-1]='M'
  # landscape[landscape.count/2-1][landscape[0].count/2-0]='E'
  # landscape[landscape.count/2+1][landscape[0].count/2-2]='O'
  # landscape[landscape.count/2+1][landscape[0].count/2-1]='V'
  # landscape[landscape.count/2+1][landscape[0].count/2+0]='E'
  # landscape[landscape.count/2+1][landscape[0].count/2+1]='R'
  # puts "\e[H\e[2J"
  # (0...landscape[0].count+2).each {|column| print'I'}
  # puts
  # (0...landscape.count).each {|row| puts 'H'+landscape[row].map{|i| i == 0 ? i = ' ' : i.nil? ? i = ' ' : i = i}.join+"H\n"}
  # (0...landscape[0].count+2).each {|column| print'I'}
  # puts
  # puts generation
end

pattern=[
  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],
  [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0],
  [0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1],
  [0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1],
  [1,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
  [1,1,0,0,0,0,0,0,0,0,1,0,0,0,1,0,1,1,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0,0,0],
  [0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],
  [0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
  [0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
]

single = [
  [1],
  [1],
  [1],
  [1],
  [1],
  [1],
  [1],
  [1],
  [1],
  [1],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [],
  [0,0,0,0,0,0,0],
  [0,0,0,1,1,1,0],
  [0,0,1,1,1,0,0],
  [0,0,1,0,0,0,0]
]

acorn = [
  [0,1,0,0,0,0,0],
  [0,0,0,1,0,0,0],
  [1,1,0,0,1,1,1],
]

r_pentamino = [
  [0,0,1,1,0],
  [0,1,1,0,0],
  [0,0,1,0,0],
]

clock = [
  [0,0,0,0,1,0,0,1,0,0,0,0,0],
  [0,0,0,0,1,1,1,1,0,0,0,0,0],
  [0,0,0,0,0,0,0,0,0,0,0,0,0],
  [0,0,0,0,1,1,1,1,0,0,0,0,0],
  [1,1,0,1,0,0,0,0,1,0,1,1,0],
  [0,1,0,1,0,0,1,0,1,0,1,0,0],
  [0,1,0,1,0,0,1,0,1,0,1,0,0],
  [1,1,0,1,0,1,0,0,1,0,1,1,0],
  [0,0,0,0,1,1,1,1,0,0,0,0,0],
  [0,0,0,0,0,0,0,0,0,0,0,0,0],
  [0,0,0,0,1,1,1,1,0,0,0,0,0],
  [0,0,0,0,1,0,0,1,0,0,0,0,0],
]

play_game(r_pentamino)
