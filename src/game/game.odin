// Pure rules: no platform imports, so this compiles natively (tests) and for js_wasm32.
//
// The hall is a COLS by ROWS grid. A table is one tile with four chairs on its orthogonal neighbours
// (seat 0 north, 1 east, 2 south, 3 west). Guests are fixed in their chairs; the tabletop turns, so the
// items on the place settings move round the guests. Each turn resolves only the table that was turned.
package game

SCREEN_W :: 240
SCREEN_H :: 192
TILE     :: 16
HUD_H    :: 16
COLS     :: SCREEN_W / TILE            // 15
ROWS     :: (SCREEN_H - HUD_H) / TILE  // 11

SEATS            :: 4
MAX_TABLES       :: 4
CRANKS_PER_TABLE :: 2
MAX_EVENTS       :: 16
WOUNDS_TO_DIE    :: 2
// A table is seen from its tile and chairs plus one more tile, so from a Chebyshev distance of 2 from the table tile.
WITNESS_RANGE    :: 2

Phase :: enum {
	Title,
	Playing,
}

Outcome :: enum {
	Undecided,
	Won,
	Lost_Caught,
	Lost_Out_Of_Turns,
	Lost_Wrong_Death,
}

Dir :: enum {
	Up,
	Down,
	Left,
	Right,
}

Guest_Id :: enum u8 {
	None,
	Baron,
	Widow,
	Cousin,
	Chef,
	Vicar,
	Hound,
}

Item :: enum u8 {
	None,
	Knife,
	Fork,
	Poisoned_Cup,
	Napkin,
	Marital_Aid, // no effect at all; it is just embarrassing
}

Spin :: enum u8 {
	Clockwise,
	Counter_Clockwise,
}

// Offsets of the four chairs from the table tile, in seat order (north, east, south, west).
SEAT_OFFSETS := [SEATS][2]int{{0, -1}, {1, 0}, {0, 1}, {-1, 0}}

Crank :: struct {
	pos:     [2]int,
	spin:    Spin,
	present: bool,
}

Table_Def :: struct {
	pos:    [2]int,
	seats:  [SEATS]Guest_Id,
	places: [SEATS]Item, // the place setting in front of each seat
	cranks: [CRANKS_PER_TABLE]Crank,
}

Level :: struct {
	name:        string,
	turn_limit:  int,
	par:         int, // the fewest turns that win; tests check the solver agrees
	start:       [2]int,
	tables:      [MAX_TABLES]Table_Def,
	table_count: int,
	must_die:    bit_set[Guest_Id],
	must_live:   bit_set[Guest_Id],
}

Guest_State :: struct {
	alive:  bool,
	wounds: u8,
}

Event_Kind :: enum {
	Drank,
	Stabbed,
	Wounded,
	Bitten,
	Napkin_Saved,
	Died,
}

Event :: struct {
	kind: Event_Kind,
	who:  Guest_Id, // the guest it happened to
	by:   Guest_Id, // the guest who did it, or None
}

// The whole state of a play. It holds its own copy of the level, whose place settings change as tables turn.
Game :: struct {
	phase:      Phase,
	level:      int,
	lv:         Level,
	guests:     [Guest_Id]Guest_State,
	player:     [2]int,
	turns_used: int,
	outcome:    Outcome,
	report:     [MAX_EVENTS]Event, // what the last table turn did, for the page to narrate
	report_len: int,
}

new_game :: proc(lv: Level) -> Game {
	g := Game{phase = .Playing, lv = lv, player = lv.start}
	for i in 0 ..< lv.table_count {
		for who in lv.tables[i].seats {
			if who != .None {
				g.guests[who].alive = true
			}
		}
	}
	return g
}

load_level :: proc(index: int) -> Game {
	g := new_game(LEVELS[index])
	g.level = index
	return g
}

init :: proc() -> Game {
	g := load_level(0)
	g.phase = .Title
	return g
}

begin :: proc(g: ^Game) {
	g.phase = .Playing
}

restart :: proc(g: ^Game) {
	g^ = load_level(g.level)
}

advance :: proc(g: ^Game) {
	g^ = load_level((g.level + 1) % LEVEL_COUNT)
}

grudge_of :: proc(who: Guest_Id) -> Guest_Id {
	switch who {
	case .Baron:  return .Widow
	case .Widow:  return .Cousin
	case .Cousin: return .Baron
	case .Chef:   return .Vicar
	case .Vicar:  return .Chef
	case .Hound, .None: // the Hound's grudge is against knife holders, handled in resolve
	}
	return .None
}

is_alive :: proc(g: ^Game, who: Guest_Id) -> bool {
	return who != .None && g.guests[who].alive
}

// Tables and their chairs are solid; the rest of the hall is walkable.
blocked :: proc(lv: ^Level, x, y: int) -> bool {
	if x < 0 || x >= COLS || y < 0 || y >= ROWS {
		return true
	}
	p := [2]int{x, y}
	for i in 0 ..< lv.table_count {
		t := lv.tables[i].pos
		if t == p {
			return true
		}
		for off in SEAT_OFFSETS {
			if t + off == p {
				return true
			}
		}
	}
	return false
}

// Walking is free (only table turns count against a level's limit). Returns whether the player moved.
walk :: proc(g: ^Game, d: Dir) -> bool {
	if g.phase != .Playing || g.outcome != .Undecided {
		return false
	}
	n := g.player
	switch d {
	case .Up:    n.y -= 1
	case .Down:  n.y += 1
	case .Left:  n.x -= 1
	case .Right: n.x += 1
	}
	if blocked(&g.lv, n.x, n.y) {
		return false
	}
	g.player = n
	return true
}

DIR_OFFSETS := [4][2]int{{0, -1}, {0, 1}, {-1, 0}, {1, 0}}

// Tap-to-walk: go to any tile reachable on foot. Walking is free, so this is one instant move; the route
// round tables and chairs is only checked, not drawn. Returns whether the player moved.
walk_to :: proc(g: ^Game, x, y: int) -> bool {
	if g.phase != .Playing || g.outcome != .Undecided || blocked(&g.lv, x, y) || g.player == {x, y} {
		return false
	}
	reached: [ROWS][COLS]bool
	queue: [ROWS * COLS][2]int
	head, tail := 0, 1
	queue[0] = g.player
	reached[g.player.y][g.player.x] = true
	for head < tail {
		p := queue[head]
		head += 1
		for off in DIR_OFFSETS {
			n := p + off
			if blocked(&g.lv, n.x, n.y) || reached[n.y][n.x] {
				continue
			}
			reached[n.y][n.x] = true
			queue[tail] = n
			tail += 1
		}
	}
	if !reached[y][x] {
		return false
	}
	g.player = {x, y}
	return true
}

// Turn the table whose crank the player is standing on. Returns whether a table turned.
crank :: proc(g: ^Game) -> bool {
	if g.phase != .Playing || g.outcome != .Undecided || g.turns_used >= g.lv.turn_limit {
		return false
	}
	for ti in 0 ..< g.lv.table_count {
		for c in g.lv.tables[ti].cranks {
			if c.present && c.pos == g.player {
				turn_table(g, ti, c.spin)
				return true
			}
		}
	}
	return false
}

turn_table :: proc(g: ^Game, ti: int, spin: Spin) {
	g.report_len = 0
	tb := &g.lv.tables[ti]
	step := spin == .Clockwise ? 1 : SEATS - 1
	old := tb.places
	for s in 0 ..< SEATS {
		tb.places[(s + step) % SEATS] = old[s]
	}
	g.turns_used += 1
	happened := resolve(g, ti)
	judge(g, ti, happened)
}

add_event :: proc(g: ^Game, kind: Event_Kind, who, by: Guest_Id) {
	if g.report_len < MAX_EVENTS {
		g.report[g.report_len] = {kind, who, by}
		g.report_len += 1
	}
}

kill :: proc(g: ^Game, who, by: Guest_Id) {
	g.guests[who].alive = false
	add_event(g, .Died, who, by)
}

Effect_Kind :: enum {
	Poison,
	Stab,
	Wound,
	Bite,
}

// Work out everything that happens at one table from its current arrangement, all at once, so simultaneous
// strikes all land. Returns whether anything was attempted (a napkin that saves a guest still counts).
resolve :: proc(g: ^Game, ti: int) -> bool {
	tb := &g.lv.tables[ti]
	Effect :: struct {
		seat: int, // the seat it lands on
		kind: Effect_Kind,
		by:   Guest_Id,
	}
	effects: [2 * SEATS]Effect
	n := 0

	for s in 0 ..< SEATS {
		if is_alive(g, tb.seats[s]) && tb.places[s] == .Poisoned_Cup {
			effects[n] = {s, .Poison, .None}
			n += 1
		}
	}
	for s in 0 ..< SEATS {
		holder := tb.seats[s]
		o := (s + 2) % SEATS // the seat across the table
		victim := tb.seats[o]
		if !is_alive(g, holder) || !is_alive(g, victim) {
			continue
		}
		if holder == .Hound {
			if tb.places[o] == .Knife {
				effects[n] = {o, .Bite, holder}
				n += 1
			}
		} else if grudge_of(holder) == victim {
			#partial switch tb.places[s] {
			case .Knife:
				effects[n] = {o, .Stab, holder}
				n += 1
			case .Fork:
				effects[n] = {o, .Wound, holder}
				n += 1
			}
		}
	}
	// A cup is drunk (or spilled on a napkin) once; one in front of an empty or dead seat stays put.
	for s in 0 ..< SEATS {
		if is_alive(g, tb.seats[s]) && tb.places[s] == .Poisoned_Cup {
			tb.places[s] = .None
		}
	}

	for e in effects[:n] {
		victim := tb.seats[e.seat]
		if tb.places[e.seat] == .Napkin {
			tb.places[e.seat] = .None // the napkin takes the first thing aimed at its guest
			add_event(g, .Napkin_Saved, victim, e.by)
			continue
		}
		if !g.guests[victim].alive {
			continue // already dead from another effect in this same moment
		}
		switch e.kind {
		case .Poison:
			add_event(g, .Drank, victim, e.by)
			kill(g, victim, e.by)
		case .Stab:
			add_event(g, .Stabbed, victim, e.by)
			kill(g, victim, e.by)
		case .Bite:
			add_event(g, .Bitten, victim, e.by)
			kill(g, victim, e.by)
		case .Wound:
			add_event(g, .Wounded, victim, e.by)
			g.guests[victim].wounds += 1
			if g.guests[victim].wounds >= WOUNDS_TO_DIE {
				kill(g, victim, e.by)
			}
		}
	}
	return n > 0
}

seen_from :: proc(player, table: [2]int) -> bool {
	d := player - table
	return max(abs(d.x), abs(d.y)) <= WITNESS_RANGE
}

// Decide the level after a turn: caught, a guest who had to live died, the goal is met, or the turns ran out.
judge :: proc(g: ^Game, ti: int, happened: bool) {
	if happened && seen_from(g.player, g.lv.tables[ti].pos) {
		g.outcome = .Lost_Caught
		return
	}
	for who in g.lv.must_live {
		if !g.guests[who].alive {
			g.outcome = .Lost_Wrong_Death
			return
		}
	}
	all_dead := true
	for who in g.lv.must_die {
		if g.guests[who].alive {
			all_dead = false
		}
	}
	if all_dead {
		g.outcome = .Won
	} else if g.turns_used >= g.lv.turn_limit {
		g.outcome = .Lost_Out_Of_Turns
	}
}

// The first thing wrong with a level's data, or "" if it is sound. Tests run this over every level.
level_problem :: proc(lv: Level) -> string {
	if lv.table_count < 1 || lv.table_count > MAX_TABLES {
		return "table_count out of range"
	}
	if lv.par < 1 || lv.par > lv.turn_limit {
		return "par must be between 1 and turn_limit"
	}
	if lv.must_die & lv.must_live != {} {
		return "a guest is both must_die and must_live"
	}
	if lv.must_die == {} {
		return "nobody must die"
	}
	solid: [ROWS][COLS]bool
	seen: [Guest_Id]int
	for i in 0 ..< lv.table_count {
		tb := lv.tables[i]
		cells: [1 + SEATS][2]int
		cells[0] = tb.pos
		for s in 0 ..< SEATS {
			cells[1 + s] = tb.pos + SEAT_OFFSETS[s]
		}
		for c in cells {
			if c.x < 0 || c.x >= COLS || c.y < 0 || c.y >= ROWS {
				return "a table or chair is off the hall"
			}
			if solid[c.y][c.x] {
				return "tables or chairs overlap"
			}
			solid[c.y][c.x] = true
		}
		for who in tb.seats {
			seen[who] += 1
		}
	}
	for who in Guest_Id {
		if who != .None && seen[who] > 1 {
			return "a guest sits twice"
		}
	}
	for who in lv.must_die + lv.must_live {
		if who == .None || seen[who] == 0 {
			return "a goal names a guest who is not seated"
		}
	}
	var := lv
	if blocked(&var, lv.start.x, lv.start.y) {
		return "the player starts on a blocked tile"
	}
	for i in 0 ..< lv.table_count {
		cranks := 0
		for c in lv.tables[i].cranks {
			if c.present {
				cranks += 1
				if blocked(&var, c.pos.x, c.pos.y) {
					return "a crank is on a blocked tile"
				}
			}
		}
		if cranks == 0 {
			return "a table has no crank"
		}
	}
	return ""
}
