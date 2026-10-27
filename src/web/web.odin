// Thin browser layer: input, drawing, and the frame loop. Everything else is in package game.
#+build js
package main

import "base:runtime"
import "core:fmt"
import "core:sys/wasm/js"
import "tggd:game"

foreign import canvas "canvas"
@(default_calling_convention = "contextless")
foreign canvas {
	// rgb is 0xRRGGBB; coordinates are logical pixels, y down.
	fill_rect :: proc(x, y, w, h: f32, rgb: u32, alpha: f32) ---
	// Bitmap text (m5x7). y is the baseline; scale is a whole number; x is the centre when centered.
	draw_text :: proc(x, y: f32, text: string, rgb: u32, scale: i32, centered: bool) ---
}

state: game.Game

GUEST_COLORS := [game.Guest_Id]u32 {
	.None   = 0x566c86,
	.Baron  = 0xb13e53,
	.Widow  = 0x5d275d,
	.Cousin = 0x38b764,
	.Chef   = 0xffa300,
	.Vicar  = 0x29adff,
	.Hound  = 0xa7f070,
}
GUEST_LETTERS := [game.Guest_Id]string {
	.None = "", .Baron = "B", .Widow = "W", .Cousin = "C", .Chef = "H", .Vicar = "V", .Hound = "D",
}
ITEM_LETTERS := [game.Item]string {
	.None = "", .Knife = "k", .Fork = "f", .Poisoned_Cup = "p", .Napkin = "n", .Marital_Aid = "m",
}

main :: proc() {
	state = game.init()
	js.add_window_event_listener(.Key_Down, nil, on_key_down)
}

// Space, Enter or a tap: start, crank, or (after the level ends) go on or try again.
act :: proc() {
	switch {
	case state.phase == .Title:
		game.begin(&state)
	case state.outcome == .Undecided:
		game.crank(&state)
	case state.outcome == .Won:
		game.advance(&state)
	case:
		game.restart(&state)
	}
}

on_key_down :: proc(e: js.Event) {
	handled := true
	switch e.key.code {
	case "ArrowLeft", "KeyA":  game.walk(&state, .Left)
	case "ArrowRight", "KeyD": game.walk(&state, .Right)
	case "ArrowUp", "KeyW":    game.walk(&state, .Up)
	case "ArrowDown", "KeyS":  game.walk(&state, .Down)
	case "KeyR":
		if state.phase == .Playing {
			game.restart(&state)
		}
	case "Space", "Enter":
		if !e.key.repeat {
			act()
		}
	case:
		handled = false
	}
	if handled {
		js.event_prevent_default()
	}
}

// Called by the page on a tap of the canvas.
@(export)
tap :: proc "c" () {
	context = runtime.default_context()
	act()
}

// QA hook (index.html#level=N, 1-based): jump straight to a level.
@(export)
qa_level :: proc "c" (n: i32) {
	context = runtime.default_context()
	if n >= 1 && int(n) <= game.LEVEL_COUNT {
		state = game.load_level(int(n) - 1)
	}
}

@(export)
step :: proc(dt: f64, c: runtime.Context) -> bool {
	context = runtime.default_context()
	draw()
	free_all(context.temp_allocator)
	return true
}

OUTCOME_TEXT := [game.Outcome]string {
	.Undecided         = "",
	.Won               = "Nicely done. Nobody saw a thing.",
	.Lost_Caught       = "You were seen. Awkward.",
	.Lost_Out_Of_Turns = "Dinner is over. Nobody died.",
	.Lost_Wrong_Death  = "The wrong person died.",
}

tile_xy :: proc(p: [2]int) -> (f32, f32) {
	return f32(p.x * game.TILE), f32(p.y * game.TILE + game.HUD_H)
}

draw :: proc() {
	fill_rect(0, 0, game.SCREEN_W, game.SCREEN_H, 0x1a1c2c, 1)
	cx := f32(game.SCREEN_W / 2)
	if state.phase == .Title {
		draw_text(cx, 50, "Table Turners", 0xf4f4f4, 3, true)
		draw_text(cx, 74, "of SPLORR!!", 0xffec27, 3, true)
		draw_text(cx, 110, "Turn the tables. Betray everyone.", 0x94b0c2, 1, true)
		draw_text(cx, 170, "Press Space or tap to start", 0xf4b41b, 1, true)
		return
	}
	T :: game.TILE
	for y in 0 ..< game.ROWS {
		for x in 0 ..< game.COLS {
			shade: u32 = (x + y) % 2 == 0 ? 0x333c57 : 0x2b3150
			fill_rect(f32(x * T), f32(y * T + game.HUD_H), T, T, shade, 1)
		}
	}
	for ti in 0 ..< state.lv.table_count {
		tb := state.lv.tables[ti]
		for c in tb.cranks {
			if c.present {
				x, y := tile_xy(c.pos)
				fill_rect(x + 2, y + 2, T - 4, T - 4, 0x73eff7, 1)
				draw_text(x + 8, y + 12, c.spin == .Clockwise ? ">" : "<", 0x1a1c2c, 1, true)
			}
		}
		tx, ty := tile_xy(tb.pos)
		fill_rect(tx, ty, T, T, 0x8b5a2b, 1)
		for s in 0 ..< game.SEATS {
			off := game.SEAT_OFFSETS[s]
			who := tb.seats[s]
			x, y := tile_xy(tb.pos + off)
			alive := who == .None || state.guests[who].alive
			fill_rect(x + 1, y + 1, T - 2, T - 2, alive ? GUEST_COLORS[who] : 0x333c57, 1)
			letter := alive ? GUEST_LETTERS[who] : "x"
			draw_text(x + 8, y + 12, letter, 0xf4f4f4, 1, true)
			if who != .None && state.guests[who].wounds > 0 && alive {
				fill_rect(x + 1, y + 1, 4, 4, 0xff0044, 1)
			}
			// The place setting sits on the table tile, towards its seat.
			draw_text(tx + 8 + f32(off.x * 4), ty + 10 + f32(off.y * 4), ITEM_LETTERS[tb.places[s]], 0xf4f4f4, 1, true)
		}
	}
	px, py := tile_xy(state.player)
	fill_rect(px + 3, py + 3, T - 6, T - 6, 0xf4f4f4, 1)

	fill_rect(0, 0, game.SCREEN_W, game.HUD_H, 0x000000, 1)
	draw_text(4, 11, state.lv.name, 0xffec27, 1, false)
	draw_text(cx + 40, 11, fmt.tprintf("Turns %d/%d (par %d)", state.turns_used, state.lv.turn_limit, state.lv.par), 0x94b0c2, 1, true)
	if state.outcome != .Undecided {
		fill_rect(0, 140, game.SCREEN_W, 40, 0x000000, 0.85)
		draw_text(cx, 158, OUTCOME_TEXT[state.outcome], 0xf4f4f4, 1, true)
		draw_text(cx, 172, state.outcome == .Won ? "Space: next level" : "Space: try again", 0xf4b41b, 1, true)
	}
}
