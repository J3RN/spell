class Spell
  def initialize
    @words = File.read("words").split("\n").map {|x| x.downcase}
  end

  def num_matching(one_bigrams, two_bigrams, acc = 0)
    if one_bigrams.length == 0 || two_bigrams.length == 0
      return acc
    end

    one_two = one_bigrams.index(two_bigrams.first)
    two_one = two_bigrams.index(one_bigrams.first)

    if (one_two.nil? && two_one.nil?)
      num_matching(one_bigrams.drop(1), two_bigrams.drop(1), acc)
    else
      if (one_two != nil && (two_one.nil? ? true : one_two <= two_one))
        num_matching(one_bigrams.drop(one_two + 1), two_bigrams.drop(1), acc + 1)
      elsif (two_one != nil && (one_two.nil? ? true : two_one < one_two))
        num_matching(one_bigrams.drop(1), two_bigrams.drop(two_one + 1), acc + 1)
      else
        raise 'Impossible Error'
      end
    end
  end

  def bigramate(word)
    bigrams = []
    for i in (0..(word.length - 2))
      bigrams.push(word.slice(i, 2))
    end
    bigrams
  end

  def compare(word1, word2)
    word1_bigrams = bigramate(word1)
    word2_bigrams = bigramate(word2)

    most_bigrams = [word1_bigrams.count, word2_bigrams.count].sort.last
    num_matching(word1_bigrams, word2_bigrams).to_f / most_bigrams
  end

  def best_match(word)
    word_hash = Hash.new {|hash, key| hash[key] = compare(word, key)}

    @words.each do |dict_word|
      word_hash[dict_word]
    end

    word_hash.sort_by {|key, value| value}.last.first
  end

  def spelled_good?(word)
    @words.include?(word)
  end
end
