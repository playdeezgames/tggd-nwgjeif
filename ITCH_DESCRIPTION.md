# Itch.io page text

Page: https://thegrumpygamedev.itch.io/table-turners-of-splorr (itch game id 5242449; public; HTML, played in the browser, 720 by 576, free, custom noun "metaphor", AI disclosure Yes with Graphics, Sounds, Text & Dialog and Code ticked). Created and submitted to the jam through Claude in Chrome on October 27, 2026; the first upload was the zip from `tools/ship.sh`'s build, done by hand in the browser, not with butler.
Devlog: posted October 27, 2026 (source `devlog/20261027/devlog.md`).
Jam: https://itch.io/jam/new-wierd-game-jam-fall (New Wierd Game Jam except it's fall; theme "Turntables")
Pasted in by hand; nothing here is published by the repo.
Decision (October 27, 2026): the user is **entering the jam** and wants it **very clear that the whole thing is AI made**. Keep the disclosure at the top of the page, in the short description, on the cover and on the title screen.

## Short description

MADE ENTIRELY BY AI (Claude): turn actual tables at a dinner party until the right guest gets the knife.

(Itch.io caps this at 120 characters; this one is 104.)

## Paste this as the page description

**THIS METAPHOR WAS MADE ENTIRELY BY AI.** The code, the pixel art, the sound effects, the puzzles and this page were all made by Claude (generative AI, by Anthropic), working alongside TheGrumpyGameDev, who chose the idea and every rule. No part of it is hand-drawn, hand-written or hand-coded. It says so on the cover, on the title screen and here, so that nobody has to wonder.

Everyone at this dinner wants someone else dead. You are only the waiter.

**Table Turners of SPLORR!!** is a puzzle Metaphor about turning actual tables. Each table has four chairs, and each guest has a grudge: the Baron wants the Widow, the Widow wants the Cousin, the Cousin wants the Baron, the Chef and the Vicar want each other, and the Hound bites whoever is holding a knife. Guests never move. The tabletop does. Turn it, and the knives, forks, poisoned cups and napkins slide round to new places, and anyone holding a weapon across from the guest they hate settles it on the spot.

You never touch a knife. You only work the cranks. Cranks are linked to their tables by cable, they only turn one way, and some are close enough to the table that you would be **seen**. Be seen when something goes wrong and the dinner is over for you, too.

- **Twelve puzzles**, from "turn the knife to the Baron" to a dinner with a cup, two napkins and a fork where the Chef has to live.
- **A turn limit and a par** on every level. Every level has been solved by a computer, and the par is the fewest turns that can win it.
- Forks only wound (two wounds kill). A napkin takes the first thing aimed at its guest. A poisoned cup kills whoever it lands in front of. The Marital Aid does nothing at all. It is just embarrassing.

**Controls:** arrow keys or WASD to walk, Space to turn the crank under you, R to try the level again. On a phone or tablet: tap a tile to walk there, tap yourself to crank, or use the on-screen pad (RESET tries the level again).

Walking is free. Only table turns count.

**Made with:** Odin, compiled to WebAssembly, drawing to a plain 2D canvas. The pixel art and the sound effects were made in the Anvil of SPLORR!!, TheGrumpyGameDev's own asset tools, by Claude. The text is the m5x7 pixel font by Daniel Linssen (managore), CC0, the only part not made by AI. **Everything else is AI made.**

## Notes (not for the page)

- **The jam's AI rule:** the jam page says AI content is only allowed if it is "completely obvious that it was made by AI". That is why the disclosure is loud everywhere (page top, short description, cover banner, title screen). If the edit screen has a generative-AI disclosure field, tick it and say the same.
- Jam dates: submissions open October 26, 2026 at 7 PM and close October 31, 2026 at 7 PM (the jam runs October 27 to November 1, 2026).
- Other jam rules: no hateful language, excessive gore or nudity; credit assets (m5x7 is credited above).
- Push target: `thegrumpygamedev/table-turners-of-splorr:html` is now the real slug (the page exists). `tools/ship.sh` tests, builds with `-o:size` and zips; it only pushes with `--push`, so later updates go out that way, only when the user says so.
- On the page's Edit game screen: "Kind of project" HTML, "This file will be played in the browser" ticked, and an embed of 720 by 576 (the game is 240 by 192 and scales to fit).
- The cover is `assets/cover.png` (630 by 500, `tools/make_cover.py`) and the screenshots are `assets/screenshots/` (`tools/make_shots.sh`, headless Chrome on the real build; run `tools/build.sh` first).
