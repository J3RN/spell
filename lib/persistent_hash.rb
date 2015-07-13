require "redis"

class PersistentHash < Hash
  def initialize(redis_key = "words", redis_opts = {})
    super()

    # Set instance vars
    @key = redis_key
    @redis = Redis.new(redis_opts)

    # Grab data from Redis and merge it into self
    data = @redis.hgetall(@key).map { |word, count| [word, count.to_i] }.to_h
    self.merge!(data)
  end

  def []=(key, value)
    @redis.hset(@key, key, value)
    super
  end
end
