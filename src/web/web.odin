// Thin browser layer: input, drawing, and the frame loop. Everything else is in package game.
#+build js
package main

import "base:runtime"
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

main :: proc() {
	state = game.init()
	js.add_window_event_listener(.Key_Down, nil, on_key_down)
}

on_key_down :: proc(e: js.Event) {
	handled := true
	switch e.key.code {
	case "ArrowLeft", "KeyA":  game.walk(&state, .Left)
	case "ArrowRight", "KeyD": game.walk(&state, .Right)
	case "ArrowUp", "KeyW":    game.walk(&state, .Up)
	case "ArrowDown", "KeyS":  game.walk(&state, .Down)
	case "Space", "Enter":
		if state.phase == .Title && !e.key.repeat {
			game.begin(&state)
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
	if state.phase == .Title {
		game.begin(&state)
	}
}

@(export)
step :: proc(dt: f64, c: runtime.Context) -> bool {
	context = runtime.default_context()
	draw()
	free_all(context.temp_allocator)
	return true
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
			fill_rect(f32(x * T), f32(y * T), T, T, shade, 1)
		}
	}
	fill_rect(f32(state.px * T + 3), f32(state.py * T + 3), T - 6, T - 6, 0xf4f4f4, 1)
}
