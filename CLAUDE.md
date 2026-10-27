# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## State of the repo

Empty apart from `README.md` (the jam URL) and `DESIGN.md`. There is no code, build, or test setup yet. The chosen concept is the grid puzzle **Seating Arrangements** (see `DESIGN.md`, which also holds the parked idle-game concept "Table Turners Inc." that another session will build; do not build it here). When the first code lands, replace this section with real build/test commands (including how to run a single test) rather than leaving the template ones in "Build recipe" as the only reference.

## The project

An entry for the [New Weird Game Jam (Fall)](https://itch.io/jam/new-wierd-game-jam-fall) (the jam's URL really is spelled "wierd"). The theme is **"Turntables"**; the jam video treats the canonical reading as the phrase "turning the tables", i.e. **betrayal**.

The user's chosen title is **"Table Turners of SPLORR!!"**: a game that literally involves turning actual tables (furniture, and the betrayal pun with it). Open design questions are listed in `DESIGN.md` at the repo root (the convention in sibling jam repos such as `/home/yermom/git/tggd-20seconds`); settle them with the user and record decisions there. Check the jam page for rules on generative-AI use and submission format before shipping, and state AI use honestly on the itch page.

## Tools and knowledge to use

- **The BOK** (`/home/yermom/git/bok-of-splorr/splorr`, an additional working directory) is the user's knowledge base. Read `Home.md` first; its "Standing rules for sessions working in this vault" section is authoritative. Relevant notes: `Tech/Odin wasm recipe.md` (build, frame loop, input, and a catalogue of architecture variants), `Tech/Release standard.md`, `Tech/Shipping to itch.io.md`, `Tech/jsfxr sound effects.md`, `Gotchas.md`. Add new lessons to the BOK's `Gotchas.md`, not here. When this game exists, it also gets a `Games/` note and a row in `Home.md` there (see the vault's own CLAUDE.md).
- **Coxswain** (MCP server `coxswain`) tracks tasks. The project for this repo is `tggd-nwgjeif`; file work with `task_create` / `task_claim` / `task_complete` instead of keeping ad-hoc TODO lists. Tools need an `agent` name; this repo's agent id is `weirdo` (register it with `agent_register` first).
- **Anvil** (MCP server `anvil-prod`, source in `/home/yermom/git/anvil-of-splorr`) is the asset editor for sprites, tiles, maps, palettes and sounds. Worlds are JSON in `/home/yermom/anvil-worlds`; use `world_export` / `sound_export` to get assets into the build. Use it if the game needs art or sound made in-house; see `tggd-20seconds` for a worked example (atlas packed by a script in sprite-set order, which must match the enum in code).

## Build recipe (from the BOK; adapt when the layout exists)

The user's house stack is **Odin compiled to `js_wasm32`**, drawn on an HTML5 2D canvas through a small JS shim (no WebGL, no emscripten). Odin is `dev-2026-07` at `~/.local/bin/odin`.

```bash
odin build src -target:js_wasm32 -out:build/web/game.wasm -o:speed   # -o:size for shipping
cp "$(odin root)/core/sys/wasm/js/odin.js" build/web/
python3 -m http.server -d build/web 8000                              # wasm must be served over http, not file://
odin test src/game -collection:tggd=src -define:ODIN_TEST_THREADS=1   # native tests of the pure rules package
```

Architecture the user's recent games converge on:

- A **pure rules package** with no platform imports (clock and RNG passed in as arguments, so it is testable natively and deterministic), plus a thin `#+build js` web package that owns `step`, input and drawing. Test files are `#+build !js` (`core:testing` panics on wasm).
- `odin check` the web package with `-target:js_wasm32`, and pass `-vet-shadowing -vet-unused` explicitly, since `odin check` does not apply them.
- Seed the RNG in `main` (`rand.reset`); Odin constant arrays cannot be indexed at runtime (declare with `:=`).
- Port 8765 is often taken by another project's server; pick another and check the first response.

## Release (itch.io)

Follow the BOK's `Release standard`: `ITCH_DESCRIPTION.md`, `assets/cover.png` (630x500), `assets/screenshots/`, `devlog/YYYYMMDD/`, `tools/build.sh`, `tools/test.sh`, `tools/ship.sh`, and a one-line `shippit.sh` wrapper. `ship.sh` runs tests, builds with `-o:size`, zips `build/web` (with `index.html` at the zip root), and pushes to itch.io **only with `--push`**. Copy `tools/ship.sh` from `/home/yermom/git/tggd-20seconds` as the template. The itch account is `thegrumpygamedev`; new pages use channel `html`.

Rules that apply here:

- **Never `git push`, `shippit.sh --push` or `butler push` unless the user explicitly says so.** "Push" means `git push`; "ship" means itch.io. Don't ask which; don't do one when told the other.
- On itch.io and in all page copy, a game is a **"Metaphor"**, never a "Game" (non-games are "Toys"). The title already carries the "of SPLORR!!" brand.
- If the game uses the ROM font 8x8, ask the user before replacing it (offer DINOBYTE first, then Public Pixel).
- Don't describe or "fix" a deliberate design choice as a problem.
