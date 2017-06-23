rown_num = nil
col_num = nil

for row_num in 1..9
  line = ''
  for col_num in 1..9
    line += "  #{row_num * col_num}  "
  end
  puts line
end

(1..9).each do |row|
  line 