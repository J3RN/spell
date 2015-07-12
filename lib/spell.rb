require "redis"

class Spell
  def initialize(key = "words", alpha = 0.3, redis_opts = {})
    # Create connection to redis
    @redis = Redis.new(redis_opts)

    # Set instance vars
    @key = key
    @alpha = alpha

    # Load words from file into Redis
    File.read("words").split("\n").each do |word|
      @redis.hsetnx(@key, word.downcase, 0)
    end

    # Store word hash in memory, update from Redis
    @words = @redis.hgetall(@key).map { |word, count| [word, count.to_i] }.to_h
  end

  # Returns the number of matching bigrams between the two sets of bigrams
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

  # Returns an array of the word's bigrams (in order)
  def bigramate(word)
    bigrams = []
    for i in (0..(word.length - 2))
      bigrams.push(word.slice(i, 2))
    end
    bigrams
  end

  # Returns the weight of this word
  def weight(word)
    max_val = @redis.hvals(@key).map { |x| x.to_i }.sort.last.to_f
    @redis.hget(@key, word).to_f * (@alpha / max_val)
  end

  # Returns the ratio of matching bigrams to the maximum possible bigrams
  def compare(given_word, dict_word)
    puts "Comparing #{given_word} to #{dict_word}"

    word1_bigrams = bigramate(given_word)
    word2_bigrams = bigramate(dict_word)

    most_bigrams = [word1_bigrams.count, word2_bigrams.count].sort.last
    bigram_score = num_matching(word1_bigrams, word2_bigrams).to_f / most_bigrams

    # Return the score, with weighted by popularity
    (bigram_score + weight(dict_word)) / (1.0 + @alpha)
  end

  # Returns the closest matching word in the dictionary
  def best_match(word)
    # Get words from Redis
    words = @redis.hkeys(@key)

    # Determine weight for this word
    word_weight = @redis.hget(@key, word) * (@alpha / @max_count)

    word_hash = words.map { |key| [key, compare(word, key) + word_weight] }.to_h
    word_hash.sort_by { |key, value| value }.last.first
  end

  # Returns a boolean for whether or not 'word' is in the dictionary
  def spelled_good?(word)
    @redis.hkeys(@key).include?(word)
  end

  # Increment count on each utterance
  def add_count(word)
    @redis.hincrby(@key, word, 1)
  end
end
