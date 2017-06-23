class Trie < Hash

  attr_reader :nodes, :count, :longest

  def initialize
    super
    @nodes = @count = 0
    @longest = ''
  end

  def <<(word)
    hash = self
    word.split('').each_with_index do |l, i|
      if hash[l].nil?
        hash[l] = {}
        @nodes += 1
      end

      hash = hash[l]

      if i == word.length - 1 && hash[:''].nil? # last character of new word
        hash[:''] = :'' # mark the end of a word
        @count += 1
        @longest = word if word.length > @longest.length
      end
    end
    self
  end

  def has(word)
    hash = self
    word.split('').each_with_index do |l, i|
      return false if hash[l].nil?

      if i == word.length - 1
        return hash[l][:''] == :''
      end

      hash = hash[l]
    end
  end

  # sub_hash: a hash with the same structure as a Trie
  # parents: an array with all the previous keys
  def each(sub_hash = nil, parents = [], &block)
    sub_hash ||= self
    return to_enum(:each, sub_hash, parents) unless block_given?
    if sub_hash[:''] == :''
      yield parents.join
    end

    sub_hash.keys.each do |k|
      next if k == :''
      each(sub_hash[k], parents + [k], &block)
    end
    self
  end

end
