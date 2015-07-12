require "cinch"
require_relative "spell"

$spell = Spell.new

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "spelltesttest"
    c.server = "irc.freenode.net"
    c.channels = ["#bottest"]
  end

  on :message, /^spell: (.+)/ do |m, sentence|
    correction_count =  0
    sentence.split(/\s/).each do |given_word|
      word = given_word.match(/[\p{L}']+/).to_s.downcase

      if !$spell.spelled_good? word
        m.reply "#{word} is spelled wrong. Did you mean #{$spell.best_match(word)}"
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

bot.start
