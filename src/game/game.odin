// Pure rules: no platform imports, so this compiles natively (tests) and for js_wasm32.
package game

SCREEN_W :: 240
SCREEN_H :: 192
TILE     :: 16
COLS     :: SCREEN_W / TILE // 15
ROWS     :: SCREEN_H / TILE // 12

Phase :: enum {
	Title,
	Playing,
}

Dir :: enum {
	Up,
	Down,
	Left,
	Right,
}

Game :: struct {
	phase:  Phase,
	px, py: int, // the player's hall tile
}

init :: proc() -> Game {
	return {phase = .Title, px = COLS / 2, py = ROWS / 2}
}

begin :: proc(g: ^Game) {
	g.phase = .Playing
}

// Walking is free (only table turns will count against a level's limit). Returns whether the player moved.
walk :: proc(g: ^Game, d: Dir) -> bool {
	if g.phase != .Playing {
		return false
	}
	nx, ny := g.px, g.py
	switch d {
	case .Up:    ny -= 1
	case .Down:  ny += 1
	case .Left:  nx -= 1
	case .Right: nx += 1
	}
	if nx < 0 || nx >= COLS || ny < 0 || ny >= ROWS {
		return false
	}
	g.px, g.py = nx, ny
	return true
}
