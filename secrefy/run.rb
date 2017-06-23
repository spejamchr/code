load 'integer.rb'
load 'key.rb'
load 'message.rb'
load 'string.rb'
load 'test.rb'

def encode(string)
  message = Message.new(string)

  key = Key.new('key')

  secret = key.secrefy(message)
  secret.show_groups

  File.open 'testing.txt', 'w' do |f|
    f.write secret.text
  end

  secret = Message.new(File.read('testing.txt'))
  deciphered = key.unsecrefy(secret)
  puts
  5.times { puts "IT'S NOT WORKING!!!" } unless deciphered.text == message.text
end

def fencode(filename, key)
  string = File.read(filename)
  key = Key.new(key)
  secret = key.secrefy(Message.new(string))
  File.open filename, 'w' do |f|
    f.write secret.text
  end
end

def funencode(filename, key)
  secret = Message.new(File.read(filename))
  key = Key.new(key)
  deciphered = key.unsecrefy(secret)
  File.open filename, 'w' do |f|
    f.write deciphered.text
  end
end

##### QUALITY TESTS #####
def quality_tests(exp)
  difference = rand(2**(exp-1))
  words = Test.words(least: (difference + 2**exp), most: (difference + 2**(exp+1)))
  btest = BiasTest.new(words: words, hasher: :hasht)
  btest.show
  stream = btest.hashes.join

  PiTest.new(stream: stream).show
  # GroupsTest.new(stream: stream, bits: 1).show
  # GroupsTest.new(stream: stream, bits: 2).show
  # GroupsTest.new(stream: stream, bits: 3).show
  # GroupsTest.new(stream: stream, bits: 4).show
  # GroupsTest.new(stream: stream, bits: 5).show
  # GroupsTest.new(stream: stream, bits: 6).show
  GroupsTest.new(stream: stream, bits: 7).show
  RunsTest.new(stream: stream).show
  SqueezeTest.new(stream: stream, bits: 32).show
  stream
end

###### TESTS AGAINST RUBY'S PRNG #####
def ruby_tests(length)
  puts "\n#######################################################################"
  puts "Testing against Ruby's PRNG"
  new_stream = rand(2**length).to_s(2)

  PiTest.new(stream: new_stream).show
  GroupsTest.new(stream: new_stream, bits: 6).show
  RunsTest.new(stream: new_stream).show
  SqueezeTest.new(stream: new_stream, bits: 32).show
end



message = "Imagine a vast sheet of paper on which straight Lines, Triangles, Squares, Pentagons, Hexagons, and other figures, instead of remaining fixed in their places, move freely about, on or in the surface, but without the power of rising above or sinking below it, very much like shadows - only hard and with luminous edges - and you will then have a pretty correct notion of my country and countrymen. Alas, a few years ago, I should have said 'my universe': but now my mind has been opened to higher views of things."

encode message

stream = quality_tests(9)
ruby_tests(stream.length)
