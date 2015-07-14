require "cinch"
require_relative "spell"
require_relative "persistent_hash"

$word_list = PersistentHash.new
$spell = Spell.new($word_list)

$bot = Cinch::Bot.new do
  configure do |c|
    config = JSON.parse(File.read("settings.json"))

    $master = config["master"]

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

  on :message, /^!!top(\d)/ do |m, num_top|
    words_counts = $word_list.sort_by {|word, count| count }.last(num_top.to_i)
    words_counts.reverse!
    m.reply(words_counts.map {|set| "#{set.first}: #{set.last}"}.join(", "))
  end

  on :message, /^!!join (.*)/ do |m, channel_name|
    channel_name = channel_name.strip

    debug m.user.nick
    if m.user.nick == $master
      channel = m.bot.join(channel_name)

      if channel.nil?
        m.reply "Could not join channel #{channel_name}"
      else
        m.reply "Joined #{channel_name}!"
      end
    else
      m.reply "Why don't you join it, eh?"
    end
  end

  on :message, /^!!part/ do |m|
    if m.user.nick == $master
      if m.channel?
        m.channel.part("Goodbye, friends")
      else
        m.reply "How do you expect me to do that?"
      end
    else
      m.reply "How about *you* go take a hike, eh?"
    end
  end

  on :message, /(.*)/ do |m, sentence|
    sentence.split(/\s/).each do |given_word|
      word = given_word.match(/[\p{L}']+/).to_s.downcase

      $spell.add_count(word) if $spell.spelled_good? word
    end
  end
end
