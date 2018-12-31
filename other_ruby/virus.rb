class Grid
  COLUMNS = 160
  ROWS = 24

  def initialize
    @grid = Array.new(ROWS){Array.new(COLUMNS, '.')}
  end

  def display
    @grid.each { |row| puts row.join }
  end

  def infect
    @grid[rand(ROWS)][rand(COLUMNS)] = 'O'
  end

  def spread

  end
end

a = Grid.new
a.display
5.times do
  sleep(0.2)
  a.spread
  a.infect
  a.display
end
