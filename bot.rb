require "cinch"
require "spell"

Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.net"
    c.channels = ["#bottest"]
  end

  on :message, /^spell:/ do |m|
    m.message.split(/\s/).each do |given_word|

    end
  end
end
