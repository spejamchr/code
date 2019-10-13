# frozen_string_literal: true

require 'Parallel'

def main(dir)
  files = Dir.glob(File.join(dir, '**', '*.rb')) || []
  methods = files.flat_map do |file|
    File.read(file).scan(/\bdef ([a-z_]+\.)?([a-z_]+)/).map(&:last)
  end.uniq.sort
  puts '.' * methods.count
  used_counts = Parallel.map(methods) do |method|
    print '_'
    [
      method,
      `rg --vimgrep -w -g '*.rb' -g '*.haml' -g '*.erb' '#{method}' '#{dir}'`
      .split("\n")
      .map { |result| result.split(/:\d+:\d+:/).last.strip }
      .reject { |line| line.match?(/def ([a-z_]+\.)?#{method}/) }
      .count
    ]
  end.to_h
  puts
  unused = used_counts.select { |_, count| count.zero? }.map(&:first)

  puts unused.count
  puts unused
end

dir = ARGV[0]

if dir && File.directory?(dir)
  main(dir)
elsif dir
  puts "Directory '#{dir}' does not exist"
else
  puts 'Requires a directory'
end
