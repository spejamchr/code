# # Super simple Forth calculator
# #
# # 25 10 * 50 + .
#
# class Forth
#
#   BINARY = %w(+ - * / ** % < > <= >= == !=).freeze
#   UNARY = %w(. IF).freeze
#
#   def initialize
#     @stack = [] # use #push and #pop
#   end
#
#   def execute(atom)
#     if BINARY.include?(atom)
#       b = @stack.pop
#       a = @stack.pop
#       @stack.push a.send(atom, b)
#     elsif UNARY.include?(atom)
#       case atom
#       when '.'
#         print @stack.pop
#       when 'IF'
#
#       end
#     else # It's a number
#       num = atom.include?('.') ? atom.to_f : atom.to_i
#       @stack.push num
#     end
#   end
#
#   def forth_exec(command)
#     command.split(' ').each{ |n| execute n }
#   end
#
# end
#
# forth = Forth.new
# while true
#   command = gets.chomp
#   forth.forth_exec command
#   print " ok\n"
# end


BINARY = %w(+ - * / ** % < > <= >= == !=).freeze
UNARY = %w(. IF DUP quit).freeze
stack = []

loop do
  command = gets.chomp

  command.split(' ').each do |atom|
    if BINARY.include?(atom)
      b = stack.pop
      a = stack.pop
      stack.push a.send(atom, b)

    elsif UNARY.include?(atom)
      case atom
      when 'quit'
        exit
      when '.'
        print stack.pop
      when 'IF'
      when 'DUP'
        stack.push stack.last
      end

    else # It's a number
      num = atom.include?('.') ? atom.to_f : atom.to_i
      stack.push num
    end
  end

  print " ok\n"
end
