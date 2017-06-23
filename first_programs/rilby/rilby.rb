# rilby: a simple programming language based primarily on Ruby.
# This is the rilby compiler/translater/whatever.

# KEY = {
#   'z' => '=',
#   'q' => '==',
#   'x' => '+',
#   'j' => '-',
#   'k' => '*',
#   'v' => '/',
#   'b' => '(',
#   'y' => ')',
#   'n' => 'for',
#   'e' => 'end',
#   't' => 'if',
#   'a' => 'else',
#   'm' => 'elsif',
#   'h' => 'while',
# }
load 'key.rb'

def parse_file text
  lines = text.split("\n")
  lines.map! do |line|
    line.split(' ')
  end
  lines.map! do |line|
    line.map! do |word|
      KEY[word] || word
    end
  end
  lines.map! do |line|
    line.join(' ')
  end
  text = lines.join("\n")

  puts text
  puts
  puts '--------- Result of Code ---------'
	eval(text)
end


puts 'Parse which file?'
file_name = gets.chomp
text = File.read file_name
parse_file text
