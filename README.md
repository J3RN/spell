# spell
The spelling bot

## What is spell?

Spell is a bot to correct spelling. When in a channel with spell, simply say:
```
spell: Spell this sentance!
```
And spell will obediently reply:
```
<your nick here> meant to say "spell this sentence!"
```

## Commands

### All user commands
- `!!top<x>`: Spell will list the top `x` number of words said. Only works for single digits (on purpose).

### Master commands
- `!!annoying`: Enable annoying mode. Spell will correct everything said in all channels. Everything.
- `!!stop`: Disable annoying mode. Spell will stop correcting everything said everywhere.
- `!!join <channel>`: Spell will join that channel.
- `!!part`: Spell will leave the current channel.
- `!!add`: Adds a word to the dictionary.

*I am not responsible for anything Spell says to a normal user trying to use a master command.*

## Setup

First, you'll need to have a [Redis](http://redis.io) server running.

After downloading a dictionary file (try [ENABLE](https://code.google.com/p/dotnetperls-controls/downloads/detail?name=enable1.txt)), and saving it in the directory as `words.txt`, run:

```bash
./bin/bootstrap
```

Next, you'll need specify some configuration. Look at `settings-example.json` for an example. You may simply copy `settings-example.json` to `settings.json`, and change the fields appropriately.

Then, to start the bot, simply run:

```bash
./bin/start
```

Also, if you'd like to play around with the underlying `Spell` class, I've added:

```bash
bin/console
```

Then you can use the provided `@spell` instance

```
irb(main)> @spell.best_match('aligator')
=> "alligator"
```
