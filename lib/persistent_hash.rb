require "redis"

class PersistentHash < Hash
  def initialize(redis_key = "words", redis_opts = {})
    super()

    @key = redis_key

    @redis = Redis.new(redis_opts)
    @redis.hgetall(@key).each do |word, count|
      self[word] = count.to_i
    end
  end

  def []=(key, value)
    @redis.hset(@key, key, value)
    super
  end
end
