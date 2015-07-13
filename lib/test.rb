require "method_profiler"
require_relative "spell"

module SpellTest
  class << self
    def performance_test
      spell = Spell.new

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
    end

    def speed_test
      persisent_profiler = MethodProfiler.observe(PersistentHash)
      spell_profiler = MethodProfiler.observe(Spell)

      spell = Spell.new
      spell.best_match("aligator")

      puts persisent_profiler.report
      puts spell_profiler.report
    end
  end
end
