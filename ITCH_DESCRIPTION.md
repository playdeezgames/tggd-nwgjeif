# Itch.io page text

Page: not created yet (the ship target in `tools/ship.sh` is a guess at the slug).
Jam: https://itch.io/jam/new-wierd-game-jam-fall (New Wierd Game Jam except it's fall; theme "Turntables")
Pasted in by hand; nothing here is published by the repo.

## Short description

A dinner party Metaphor: turn the tables, literally, until the right guest gets the knife. Twelve puzzles, nobody saw a thing.

## Paste this as the page description

Everyone at this dinner wants someone else dead. You are only the waiter.

**Table Turners of SPLORR!!** is a puzzle Metaphor about turning actual tables. Each table has four chairs, and each guest has a grudge: the Baron wants the Widow, the Widow wants the Cousin, the Cousin wants the Baron, the Chef and the Vicar want each other, and the Hound bites whoever is holding a knife. Guests never move. The tabletop does. Turn it, and the knives, forks, poisoned cups and napkins slide round to new places, and anyone holding a weapon across from the guest they hate settles it on the spot.

You never touch a knife. You only work the cranks. Cranks are linked to their tables by cable, they only turn one way, and some are close enough to the table that you would be **seen**. Be seen when something goes wrong and the dinner is over for you, too.

- **Twelve puzzles**, from "turn the knife to the Baron" to a dinner with a cup, two napkins and a fork where the Chef has to live.
- **A turn limit and a par** on every level. Every level has been solved by a computer, and the par is the fewest turns that can win it.
- Forks only wound (two wounds kill). A napkin takes the first thing aimed at its guest. A poisoned cup kills whoever it lands in front of. The Marital Aid does nothing at all. It is just embarrassing.

**Controls:** arrow keys or WASD to walk, Space to turn the crank under you, R to try the level again. On a phone or tablet: tap a tile to walk there, tap yourself to crank, or use the on-screen pad (RESET tries the level again).

Walking is free. Only table turns count.

**Made with:** Odin, compiled to WebAssembly, drawing to a plain 2D canvas. The pixel art and the sound effects were made in the Anvil of SPLORR!!, TheGrumpyGameDev's own asset tools. The text is the m5x7 pixel font by Daniel Linssen (managore), CC0. The code, the art, the sounds and the puzzles were all made with Claude (generative AI) working alongside TheGrumpyGameDev, who chose the idea and every rule.

## Notes (not for the page)

- **Check the jam's AI rule before entering.** The jam page says you cannot add AI content "UNLESS it is completely obvious that it was made by AI". This game's code, art and sound were all made with Claude, and that is not obvious to a player. The user has to decide whether to enter, enter with a bolder disclosure, or release it outside the jam as a normal page (as was done with The End of the World Was Nice).
- Jam dates: submissions open October 26, 2026 at 7 PM and close October 31, 2026 at 7 PM (the jam runs October 27 to November 1, 2026).
- Other jam rules: no hateful language, excessive gore or nudity; credit assets (m5x7 is credited above).
- Push target: `thegrumpygamedev/table-turners-of-splorr:html` is a guess; set the real slug in `tools/ship.sh` once the page exists. `tools/ship.sh` tests, builds with `-o:size` and zips; it only pushes with `--push`.
- On the page's Edit game screen: "Kind of project" HTML, "This file will be played in the browser" ticked, and an embed of 720 by 576 (the game is 240 by 192 and scales to fit).
- The cover is `assets/cover.png` (630 by 500, `tools/make_cover.py`) and the screenshots are `assets/screenshots/` (`tools/make_shots.sh`, headless Chrome on the real build; run `tools/build.sh` first).
- If the edit screen has a generative-AI disclosure field, fill it in to match the "Made with" paragraph.
