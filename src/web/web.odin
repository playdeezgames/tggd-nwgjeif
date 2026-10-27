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
	// Draw a sprite from the atlas (build/web/art.png) with its top-left at x, y.
	blit :: proc(sprite: i32, x, y: f32, alpha: f32) ---
	play_sound :: proc(sound: i32) ---
	// Bitmap text (m5x7). y is the baseline; scale is a whole number; x is the centre when centered.
	draw_text :: proc(x, y: f32, text: string, rgb: u32, scale: i32, centered: bool) ---
}

state: game.Game

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
		if game.crank(&state) {
			play_report()
		}
	case state.outcome == .Won:
		game.advance(&state)
	case:
		game.restart(&state)
	}
}

// Sounds for what the last table turn did.
play_report :: proc() {
	play_sound(i32(game.Sound.Crank))
	for e in state.report[:state.report_len] {
		#partial switch e.kind {
		case .Stabbed, .Bitten, .Wounded: play_sound(i32(game.Sound.Strike))
		case .Drank:                      play_sound(i32(game.Sound.Drink))
		case .Napkin_Saved:               play_sound(i32(game.Sound.Saved))
		}
	}
	#partial switch state.outcome {
	case .Won:         play_sound(i32(game.Sound.Won))
	case .Lost_Caught: play_sound(i32(game.Sound.Caught))
	case .Undecided:
	case:              play_sound(i32(game.Sound.Lost))
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

touch_ui: bool // the page is showing the on-screen pad, so the title names it

// Called by the page when it shows the on-screen pad.
@(export)
set_touch_ui :: proc "c" (on: i32) {
	touch_ui = on != 0
}

// A tap on the canvas, in logical pixels. Start or go on when asked; otherwise tap a tile to walk there,
// or tap the tile you are standing on to crank.
@(export)
tap_at :: proc "c" (x, y: i32) {
	context = runtime.default_context()
	if state.phase != .Playing || state.outcome != .Undecided {
		act()
		return
	}
	if int(y) < game.HUD_H {
		return
	}
	tile := [2]int{int(x) / game.TILE, (int(y) - game.HUD_H) / game.TILE}
	if tile == state.player {
		act()
	} else {
		game.walk_to(&state, tile.x, tile.y)
	}
}

// The on-screen pad: 0 to 3 walk (up, down, left, right), 4 crank, 5 restart the level.
@(export)
pad :: proc "c" (code: i32) {
	context = runtime.default_context()
	switch code {
	case 0 ..= 3:
		game.walk(&state, game.Dir(code))
	case 4:
		act()
	case 5:
		if state.phase == .Playing {
			game.restart(&state)
		}
	}
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
		draw_text(cx, 100, "Turn the tables. Betray everyone.", 0x94b0c2, 1, true)
		if touch_ui {
			draw_text(cx, 128, "Tap a tile to walk there.", 0x94b0c2, 1, true)
			draw_text(cx, 140, "Tap yourself on a crank to turn it.", 0x94b0c2, 1, true)
			draw_text(cx, 170, "Tap to start", 0xf4b41b, 1, true)
		} else {
			draw_text(cx, 128, "Arrows or WASD to walk, Space to crank.", 0x94b0c2, 1, true)
			draw_text(cx, 140, "R tries the level again.", 0x94b0c2, 1, true)
			draw_text(cx, 170, "Press Space to start", 0xf4b41b, 1, true)
		}
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
				blit(i32(c.spin == .Clockwise ? game.Sprite.Crank_Cw : game.Sprite.Crank_Ccw), x, y, 1)
			}
		}
		tx, ty := tile_xy(tb.pos)
		blit(i32(game.Sprite.Table), tx, ty, 1)
		for s in 0 ..< game.SEATS {
			off := game.SEAT_OFFSETS[s]
			who := tb.seats[s]
			x, y := tile_xy(tb.pos + off)
			blit(i32(game.Sprite.Chair), x, y, 1)
			if who != .None {
				alive := state.guests[who].alive
				blit(i32(alive ? game.GUEST_SPRITES[who] : game.Sprite.Dead), x, y, 1)
				if alive && state.guests[who].wounds > 0 {
					blit(i32(game.Sprite.Wound), x, y, 1)
				}
			}
			// The place setting sits on the table tile, towards its seat.
			if item := tb.places[s]; item != .None {
				blit(i32(game.ITEM_SPRITES[item]), tx + f32(off.x * 5), ty + f32(off.y * 5), 1)
			}
		}
	}
	px, py := tile_xy(state.player)
	blit(i32(game.Sprite.Player), px, py, 1)

	fill_rect(0, 0, game.SCREEN_W, game.HUD_H, 0x000000, 1)
	draw_text(4, 11, state.lv.name, 0xffec27, 1, false)
	draw_text(cx + 40, 11, fmt.tprintf("Turns %d/%d (par %d)", state.turns_used, state.lv.turn_limit, state.lv.par), 0x94b0c2, 1, true)
	if state.outcome != .Undecided {
		fill_rect(0, 140, game.SCREEN_W, 40, 0x000000, 0.85)
		draw_text(cx, 158, OUTCOME_TEXT[state.outcome], 0xf4f4f4, 1, true)
		draw_text(cx, 172, state.outcome == .Won ? "Space: next level" : "Space: try again", 0xf4b41b, 1, true)
	}
}
