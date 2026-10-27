# Table Turners of SPLORR!! — design

Entry for the [New Weird Game Jam (Fall)](https://itch.io/jam/new-wierd-game-jam-fall). Theme "Turntables": read as "turning the tables", i.e. betrayal, and taken literally as turning actual tables.

## Chosen concept (this repo): Seating Arrangements

A grid puzzle. A top-down banquet hall full of tables. The player can only **turn a table 90°** (or a lazy Susan on it); everything on that table turns with it. Every guest is secretly plotting against someone. Each level asks the player to turn tables until the right guest gets the poisoned cup, the right knife lands in front of the right back, and the player is never at a table when it goes off.

- **Betrayal:** the player is the betrayer, but never stabs anyone. They only turn tables; the guests do the rest.
- **Rules are pure and turn-based**, in the style of Roomba Rights (BOK). A breadth-first search over table orientations, calling the real turn function, proves every level is solvable and is run as a test.
- **Scope:** about 12 hand-made levels; art and sound made in Anvil. Text and UI follow the BOK's conventions (a game is a "Metaphor" on itch.io; "yer" voice where it suits).
- **Main risk:** level design. A bad level feels unfair; the solver catches impossible ones, not dull ones.

### Decisions (settled with the user)

- **Turning:** square tables only, turned in 90° steps (clockwise or counter-clockwise). **The tabletop turns; the chairs and guests stay put.** (Corrected October 27, 2026: if guests turned with the table, nothing at a table would ever change relative to anything else, and there would be no puzzle.) Each table has 4 seats, one per side, and each seat has a place setting in front of it holding at most one item. A turn rotates the place settings, with their items, one step round the fixed guests. No lazy Susan ring and no round tables in v1.
- **Betrayals ("strike what's in front"):** after each table turn, a guest whose place setting holds a weapon strikes the guest **directly across the table**, but only if that guest is the one their grudge names. Only across; never beside. No chain reactions in v1.
- **Items:**
  - *Knife*: weapon. Its holder stabs their grudge target if that guest is across.
  - *Poisoned cup*: the guest at the place setting drinks it, whoever they are, when the turn resolves.
  - *Fork*: a weak weapon, used like the knife but it only wounds. Two wounds kill. (The candlestick is dropped; the fork replaces it.)
  - *Napkin*: protects the guest at that place setting from the first harmful effect (a strike, a wound or a cup) that would land on them, then is used up.
  - *Marital Aid*: **no game effect at all.** It is just embarrassing. It sits on place settings and turns with the table like any other item, and gets a joke in the text when a guest ends a turn in front of it.
- **Cast:** a small set of archetypes, each with a fixed grudge, reused across levels (about 6 are planned; the proposed list is below).
- **Player and cranks:** the player walks a grid hall (arrows). Each table has up to **two cranks** on hall tiles, linked to it by cables, each with its own fixed direction (a near crank that turns the quick way and a far crank that turns the slow way is the basic "seen" puzzle). Standing on a crank tile and pressing Space turns that table one step (the direction is a per-crank setting or the player's choice; to settle when building). Walking is **free**; only table turns count against the level's limit.
- **Being caught:** when a strike or poisoning lands at a table, the player is **seen if standing within one tile of that table** (any of the 8 tiles around its footprint), and the level is lost. Cranks are placed so this bites. Line of sight and walls are not in v1.
- **Input:** keyboard (arrows move, Space cranks), an on-screen touch pad (directions plus a crank button), and tap-a-tile-to-walk (needs pathfinding over free hall tiles; walking is free so it just teleports along the shortest path with no extra cost).
- **Level end:** each level has a goal (e.g. the Baron is poisoned and you are unsuspected) and a limit on table turns. The par count is the replay hook. The limit also bounds the solver search.
- **Look:** Anvil-made 16x16 sprites with a 16-colour palette on a screen of about 240x192, with sounds also made in Anvil. Text is drawn from a bitmap font sheet (not canvas `fillText`; see the BOK's Gotchas).

### Cast (confirmed)

Six archetypes, each with a fixed grudge that names *another archetype*, not an individual: the **Baron** (grudge: the Widow), the **Widow** (the Cousin), the **Cousin** (the Baron), the **Chef** (the Vicar), the **Vicar** (the Chef) and the **Hound** (whoever holds a knife). Levels pick a subset and seat them at the tables. A guest only strikes with a weapon at their own place setting.

### Cranks and resolution (confirmed)

- **Crank direction:** fixed per crank, shown by an arrow on it; the level designer chooses. Four turns return a table to its start, which keeps the solver state small.
- **Resolution order of one turn:** (1) the crank's table turns one step; (2) all effects are worked out at once from the new arrangement: poisoned cups hit the guest at their place, and each weapon holder whose grudge target is across strikes them; a napkin cancels the first incoming effect on its guest and is used up; (3) wounds are added and anyone at two wounds, or hit by a knife or a cup, dies; simultaneous strikes all land, so two guests can kill each other; (4) the caught check runs against every table where a strike, wound, cup or death happened this turn.

### Rules as built (src/game)

- A table is one tile with four chairs on its orthogonal neighbours (seat 0 north, 1 east, 2 south, 3 west); the chairs and the table are solid. The hall is 15 by 11 tiles under a 16 px HUD row.
- **Only the table that was turned resolves.** Other tables are untouched, so a knife that has already struck does not strike again unless a turn brings it round again. "Seen" is a Chebyshev distance of 2 or less from the table tile (the table, its chairs and one more tile), and only when something was attempted at that table that turn (a napkin saving someone counts).
- The Hound needs no weapon: it bites, and kills, the guest across if that guest's place setting holds a knife. A poisoned cup kills outright, is used up when drunk, and stays put in front of an empty or dead seat. A guest can be hit by a cup and a strike in the same moment; the napkin takes the first.
- A level is won when every `must_die` guest is dead and no `must_live` guest has died; it is lost if seen, if a `must_live` guest dies, or when the turns run out. Each guest archetype appears at most once per level.
- `solve` (native only, `src/game/solver.odin`) is a layered breadth-first search over the real `walk` and `crank`; tests check every level is sound, solvable, and that its `par` equals the solver's minimum.

### Still open

- Palette, font choice and the title-screen look.
- Level goals as data: which guests must die, which must live, and whether the napkin counts as a goal item.
- The text voice for guests and the Marital Aid jokes.

## Parked concept (for another session): Table Turners Inc.

**Not being built in this repo/session.** A weird idle/incremental: the player runs a one-person table-turning service. Customers pay to have their table turned, which betrays whoever sits across it. Earn money, hire hands, unlock bigger tables (bistro, banquet, state dinner, cosmic). The hired hands eventually turn on the player: the first hire is loyal, the twentieth is plotting.

- Plain DOM, saves in localStorage, deterministic pure core (like Murder Hobo / Check Yer Butthole in the BOK).
- Smallest scope of the three concepts, which leaves room for writing and polish.
- Main risk: incrementals feel thin unless the writing and the late-game twist land.
- A possible hybrid: reuse #1's puzzle levels with this concept's hired-hands betrayal arc as the story.

## Considered and not chosen: The Lazy Susan Conspiracy

Deduction roguelite: one round table, eight guests, a rotating centre. Each course the player turns the table and the dishes slide to new people; reactions reveal who is loyal and who will betray. Guests are named individuals who remember what you did. Needs careful balance; parked, not planned.
