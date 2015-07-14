require "cinch"
require_relative "spell"
require_relative "persistent_hash"

$word_list = PersistentHash.new
$spell = Spell.new($word_list)

$bot = Cinch::Bot.new do
  configure do |c|
    config = JSON.parse(File.read("settings.json"))

    c.nick =      config["nick"]
    c.password =  config["password"]
    c.server =    config["server"]
    c.channels =  config["channels"]
  end

  on :message, /^spell: (.+)/ do |m, sentence|
    correction_count =  0
    sentence.split(/\s/).each do |given_word|
      word = given_word.match(/[\p{L}']+/).to_s.downcase

      if !$spell.spelled_good? word
        m.reply "'#{word}' is spelled wrong. Did you mean '#{$spell.best_match(word)}'?"
        correction_count += 1
      end
    end

    if correction_count == 0
      m.reply "Looks good to me!"
    end
  end

  on :message, /(.*)/ do |m, sentence|
    sentence.split(/\s/).each do |given_word|
      word = given_word.match(/[\p{L}']+/).to_s.downcase

      $spell.add_count(word) if $spell.spelled_good? word
    end
  end
end
