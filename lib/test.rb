require "redis"
require_relative "spell"

redis = Redis.new
spell = Spell.new(redis)

test_contents = File.read("misspellings.txt")

test_contents.each_line do |line|
  key = line.match(/.*(?=\-\>)/)
  value = line.match(/(?<=\-\>).*/)

  result = spell.best_match(key)
  if result != value
    puts "Expected #{value} but was #{result}"
  else
    puts "#{value} passed"
  end
end
