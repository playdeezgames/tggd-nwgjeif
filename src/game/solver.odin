#+build !js
package game

// Breadth-first search over a level, calling the real `walk` and `crank`. Walking is free, so the search
// goes layer by layer: all positions reachable on foot at the current turn count, then one crank each.
// Native only (it needs a map), used by the tests to prove every level can be won and to check its par.

Key :: struct {
	player: [2]u8,
	places: [MAX_TABLES][SEATS]Item,
	alive:  [Guest_Id]bool,
	wounds: [Guest_Id]u8,
}

key_of :: proc(g: ^Game) -> Key {
	k := Key{player = {u8(g.player.x), u8(g.player.y)}}
	for i in 0 ..< g.lv.table_count {
		k.places[i] = g.lv.tables[i].places
	}
	for who in Guest_Id {
		k.alive[who] = g.guests[who].alive
		k.wounds[who] = g.guests[who].wounds
	}
	return k
}

// The fewest table turns that win the level, or ok = false if it cannot be won within its turn limit.
solve :: proc(lv: Level) -> (turns: int, ok: bool) {
	visited := make(map[Key]struct{})
	defer delete(visited)
	layer := make([dynamic]Game)
	defer delete(layer)
	next := make([dynamic]Game)
	defer delete(next)

	start := new_game(lv)
	visited[key_of(&start)] = {}
	append(&layer, start)

	for _ in 0 ..= lv.turn_limit {
		for i := 0; i < len(layer); i += 1 {
			for d in Dir {
				c := layer[i]
				if walk(&c, d) {
					k := key_of(&c)
					if k not_in visited {
						visited[k] = {}
						append(&layer, c)
					}
				}
			}
		}
		for g in layer {
			c := g
			if !crank(&c) {
				continue
			}
			#partial switch c.outcome {
			case .Won:
				return c.turns_used, true
			case .Undecided:
				k := key_of(&c)
				if k not_in visited {
					visited[k] = {}
					append(&next, c)
				}
			}
		}
		clear(&layer)
		layer, next = next, layer
		if len(layer) == 0 {
			break
		}
	}
	return 0, false
}
