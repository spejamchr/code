class String
  # Colors
  def default_color;  "\033[39m#{self}\033[0m" end
  def black;          "\033[30m#{self}\033[0m" end
  def red;            "\033[31m#{self}\033[0m" end
  def green;          "\033[32m#{self}\033[0m" end
  def brown;          "\033[33m#{self}\033[0m" end
  def blue;           "\033[34m#{self}\033[0m" end
  def magenta;        "\033[35m#{self}\033[0m" end
  def cyan;           "\033[36m#{self}\033[0m" end
  def gray;           "\033[37m#{self}\033[0m" end
  def dark_gray;      "\033[90m#{self}\033[0m" end
  def lt_red;         "\033[91m#{self}\033[0m" end
  def lt_green;       "\033[92m#{self}\033[0m" end
  def lt_yellow;      "\033[93m#{self}\033[0m" end
  def lt_blue;        "\033[94m#{self}\033[0m" end
  def lt_magenta;     "\033[95m#{self}\033[0m" end
  def lt_cyan;        "\033[96m#{self}\033[0m" end
  def white;          "\033[97m#{self}\033[0m" end
  
  # Backgrounds
  def bg_default;     "\033[49m#{self}\033[0m" end
  def bg_black;       "\033[40m#{self}\033[0m" end
  def bg_red;         "\033[41m#{self}\033[0m" end
  def bg_green;       "\033[42m#{self}\033[0m" end
  def bg_brown;       "\033[43m#{self}\033[0m" end
  def bg_blue;        "\033[44m#{self}\033[0m" end
  def bg_magenta;     "\033[45m#{self}\033[0m" end
  def bg_cyan;        "\033[46m#{self}\033[0m" end
  def bg_gray;        "\033[47m#{self}\033[0m" end
  def bg_dark_gray;   "\033[100m#{self}\033[0m" end
  def bg_lt_red;      "\033[101m#{self}\033[0m" end
  def bg_lt_green;    "\033[102m#{self}\033[0m" end
  def bg_lt_yellow;   "\033[103m#{self}\033[0m" end
  def bg_lt_blue;     "\033[104m#{self}\033[0m" end
  def bg_lt_magenta;  "\033[105m#{self}\033[0m" end
  def bg_lt_cyan;     "\033[106m#{self}\033[0m" end
  def bg_white;       "\033[107m#{self}\033[0m" end
  
  # Formatting
  def bold;           "\033[1m#{self}\033[0m" end
  def dim;            "\033[2m#{self}\033[0m" end
  def underlined;     "\033[4m#{self}\033[0m" end
  def blink;          "\033[5m#{self}\033[0m" end
  def reverse_color;  "\033[7m#{self}\033[0m" end  # Invert foreground & background
  def hidden;         "\033[8m#{self}\033[0m" end  # Good for passwords
  def no_colors
      self.gsub /\033\[\d+m/, ""
  end
end
puts 'What am I?'.bold
puts "I'm blue".blue
puts "I'm back green".bg_green
puts "I'm red and back cyan".red.bg_cyan
puts "I'm bold and green and backround red".bold.green.bg_red
puts "Can you read this?".black.bg_black
puts "This is a string".gray

b = '        '.bg_black
w = '        '.bg_white
puts "Does this blink?".blink.underlined.bold.reverse_color

brow = ('  '.bg_red + b + w + b + w + b + w + b + w + '  '.bg_red + "\n") * 4
wrow = ('  '.bg_red + w + b + w + b + w + b + w + b + '  '.bg_red + "\n") * 4

puts ' '.bg_red * (8 * 8 + 4)
4.times {puts brow + wrow}
puts ' '.bg_red * (8 * 8 + 4)

colors = %i(bg_default bg_black bg_red bg_green bg_brown bg_blue bg_magenta 
  bg_cyan bg_gray bg_dark_gray bg_lt_red bg_lt_green bg_lt_yellow bg_lt_blue 
  bg_lt_magenta bg_lt_cyan bg_white).map { |c| ' '.send(c) }
  
puts colors.join