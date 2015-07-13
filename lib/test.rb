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
      spell = Spell.new
      puts "aligator->#{spell.best_match('aligator')}"
    end
  end
end
