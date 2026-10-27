# Table Turners of SPLORR!! is in, and an AI made all of it

**This Metaphor was made entirely by AI.** Claude (generative AI, by Anthropic) wrote the code, drew the pixel art, made the sound effects, designed the twelve puzzles and wrote this post. TheGrumpyGameDev chose the idea, the title and every rule. The jam allows AI content when it is completely obvious that AI made it, so it says so on the cover, on the title screen, at the top of the page and here.

## What it is

A dinner party where everybody wants somebody else dead, and you are only the waiter. Each table has four chairs, and each guest has a grudge. Guests never move. The tabletop does. You work a crank, the tabletop turns, and the knives, forks, poisoned cups and napkins slide round to new places. Anyone holding a weapon across from the guest they hate settles it on the spot. Stand too near the table when it goes off and you are seen, and the dinner is over for you too.

The theme, "Turntables", is read as "turning the tables": betrayal. Here it is the whole game. You never touch a knife. You only turn tables.

## How it was made

- **The rules are a pure package** with no platform code, written in Odin and compiled to WebAssembly. It draws to a plain 2D canvas.
- **A solver proves every level.** A breadth-first search plays the real `walk` and `crank` functions and checks that each of the twelve levels can be won, and that the par shown is the fewest turns that can win it. A bad level feels unfair; a computer can catch an impossible one, so the tests do.
- **Art and sound** were made in the Anvil of SPLORR!!, TheGrumpyGameDev's asset editor: eighteen 16 by 16 sprites on the Sweetie-16 palette and seven small sound effects.
- **One decision changed everything.** The first draft turned the guests with the table, which meant nothing at a table ever changed. The tabletop turning under guests who stay put is what made it a puzzle.
- **Touch works.** Tap a tile to walk there, tap yourself to crank, or use the on-screen pad.

The only part not made by AI is the m5x7 pixel font by Daniel Linssen (managore), CC0.

## What is rough

Nobody has played the harder levels (par 7 and 8) except the solver. The items are cramped on a one-tile table. The Marital Aid has no effect and no joke text yet. It is just embarrassing.

Thanks for playing. If a level is unfair, say which one.
