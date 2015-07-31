require 'ruby-prof'
require_relative '../lib/spell.rb'
require_relative '../lib/persistent_hash.rb'

word_list = PersistentHash.new
spell = Spell.new(nil, word_list)

result = RubyProf.profile do
  fail 'Mismatch' unless spell.best_match('alligator') == 'alligator'
end

Dir.mkdir('profiling') unless File.exist? 'profiling'

printer = RubyProf::GraphHtmlPrinter.new(result)
printer.print(File.new("profiling/#{Time.now.to_i}-graph.html", 'w+'))

printer = RubyProf::CallStackPrinter.new(result)
printer.print(File.new("profiling/#{Time.now.to_i}-output.html", 'w+'))
