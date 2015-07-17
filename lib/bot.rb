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
    new_sentence = corrected_sentence(sentence, get_nicks(m))

    if new_sentence == sentence
      m.reply "Looks good to me!"
    else
      m.reply "#{m.user.nick} meant to say \"#{new_sentence}\""
    end
  end

  on :message, /^!!top(\d)/ do |m, num_top|
    words_counts = $word_list.sort_by { |_, count| count }.last(num_top.to_i)
    words_counts.reverse!
    m.reply(words_counts.map { |set| "#{set.first}: #{set.last}" }.join(", "))
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

  on :message, /^!!annoying/ do |m|
    if m.user.nick == $master
      @annoying_mode = true
      m.reply "Now being annoying"
    else
      m.reply "How about you shut up?"
    end
  end

  on :message, /^!!stop/ do |m|
    if m.user.nick == $master
      @annoying_mode = false
      m.reply "Alright, OK."
    else
      m.reply "How about you stop being annoying, eh?"
    end
  end

  on :message, /^!!add ([\p{L}']+)/ do |m, word|
    if m.user.nick == $master
      word = word.downcase
      $word_list[word] = 0
      m.reply "Learned #{word}"
    else
      m.reply "How about *you* learn some vocabulary, eh?"
    end
  end

  on :message, /(.*)/ do |m, sentence|
    if @annoying_mode
      new_sentence = corrected_sentence(sentence, get_nicks(m))

      if new_sentence != sentence
        m.reply "#{m.user.nick} meant to say \"#{new_sentence}\""
      end
    end

    sentence.split(/\s/).each do |given_word|
      word = given_word.match(/[\p{L}']+/).to_s.downcase

      $spell.add_count(word) if $spell.spelled_good? word
    end
  end

  helpers do

    def get_nicks(message)
      if message.channel?
        message.channel.users.keys.map { |user| user.nick }
      else
        [ message.user.nick ]
      end
    end

    def corrected_sentence(sentence, nicks)
      raw_new = sentence.split(/\s/).map do |given_word|
        trimmed_word = given_word.match(/[\p{L}']+/).to_s.downcase

        if trimmed_word == "" or $spell.spelled_good? trimmed_word or
          nicks.include? trimmed_word
          given_word
        else
          $spell.best_match(trimmed_word)
        end
      end

      raw_new.join(" ")
    end
  end
end
