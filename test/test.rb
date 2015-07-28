require 'ruby-prof'
require_relative '../lib/spell.rb'
require_relative '../lib/persistent_hash.rb'

word_list = PersistentHash.new
spell = Spell.new(nil, word_list)

result = RubyProf.profile do
  spell.best_match('aligator')
end

printer = RubyProf::FlatPrinter.new(result)
printer.print(STDOUT, sort_method: :total_time)
