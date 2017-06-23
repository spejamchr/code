linewidth = 40
table = [['Ch. 1: Getting Started',  'pg. 1'],
         ['Ch. 2: Numbers',          'pg. 9'],
         ['Ch. 3: Letters',          'pg.13'],
         ['Ch. 4: Variables',        'pg.17'],
         ['Ch. 5: Mixing It Up',     'pg.21']]
puts 'Table of Contents'.center(linewidth*2)
puts ''
table.each do |chapter|
  puts chapter[0].ljust(linewidth) + chapter[1].rjust(linewidth)
end