#+build !js
package game

import "core:testing"

@(test)
walking_waits_for_the_title :: proc(t: ^testing.T) {
	g := init()
	testing.expect(t, !walk(&g, .Left))
	begin(&g)
	testing.expect(t, walk(&g, .Left))
}

@(test)
player_stays_in_the_hall :: proc(t: ^testing.T) {
	g := init()
	begin(&g)
	for _ in 0 ..< COLS + ROWS {
		walk(&g, .Left)
		walk(&g, .Up)
	}
	testing.expect_value(t, g.px, 0)
	testing.expect_value(t, g.py, 0)
	testing.expect(t, !walk(&g, .Left))
	testing.expect(t, !walk(&g, .Up))
	for _ in 0 ..< COLS + ROWS {
		walk(&g, .Right)
		walk(&g, .Down)
	}
	testing.expect_value(t, g.px, COLS - 1)
	testing.expect_value(t, g.py, ROWS - 1)
}
