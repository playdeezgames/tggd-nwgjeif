#+build !js
package game

import "core:testing"

// One table at (7, 4) with a crank at (12, 9), far from it, and a long turn limit.
fixture :: proc(seats: [SEATS]Guest_Id, places: [SEATS]Item) -> Game {
	lv := Level {
		name = "test", turn_limit = 9, par = 1, start = {3, 9}, table_count = 1,
		must_die = {.Widow},
	}
	lv.tables[0] = {pos = {7, 4}, seats = seats, places = places}
	lv.tables[0].cranks[0] = {pos = {12, 9}, spin = .Clockwise, present = true}
	return new_game(lv)
}

@(test)
walking_waits_for_the_title :: proc(t: ^testing.T) {
	g := init()
	testing.expect(t, !walk(&g, .Left))
	begin(&g)
	testing.expect(t, walk(&g, .Left))
}

@(test)
player_stays_in_the_hall :: proc(t: ^testing.T) {
	g := load_level(0)
	for _ in 0 ..< COLS + ROWS {
		walk(&g, .Left)
		walk(&g, .Up)
	}
	testing.expect_value(t, g.player, [2]int{0, 0})
	testing.expect(t, !walk(&g, .Left))
	testing.expect(t, !walk(&g, .Up))
	for _ in 0 ..< COLS + ROWS {
		walk(&g, .Right)
		walk(&g, .Down)
	}
	testing.expect_value(t, g.player, [2]int{COLS - 1, ROWS - 1})
}

@(test)
tables_and_chairs_are_solid :: proc(t: ^testing.T) {
	g := fixture({}, {})
	g.player = {5, 4} // two west of the table tile; the west chair is at (6, 4)
	testing.expect(t, !walk(&g, .Right))
	g.player = {7, 2} // above the north chair at (7, 3)
	testing.expect(t, !walk(&g, .Down))
	testing.expect(t, walk(&g, .Left))
}

@(test)
turning_moves_place_settings_round_the_guests :: proc(t: ^testing.T) {
	g := fixture({.Baron, .None, .Widow, .None}, {.Knife, .Napkin, .None, .Marital_Aid})
	turn_table(&g, 0, .Clockwise)
	testing.expect_value(t, g.lv.tables[0].places, [SEATS]Item{.Marital_Aid, .Knife, .Napkin, .None})
	turn_table(&g, 0, .Counter_Clockwise)
	turn_table(&g, 0, .Counter_Clockwise)
	testing.expect_value(t, g.lv.tables[0].places, [SEATS]Item{.Napkin, .None, .Marital_Aid, .Knife})
	testing.expect_value(t, g.turns_used, 3)
	// The guests did not move.
	testing.expect_value(t, g.lv.tables[0].seats, [SEATS]Guest_Id{.Baron, .None, .Widow, .None})
}

@(test)
knife_kills_the_grudge_target_across :: proc(t: ^testing.T) {
	g := fixture({.Baron, .None, .Widow, .None}, {.Knife, .None, .None, .None})
	testing.expect(t, resolve(&g, 0))
	testing.expect(t, !g.guests[.Widow].alive)
	testing.expect(t, g.guests[.Baron].alive)
}

@(test)
knife_ignores_a_target_that_is_not_the_grudge :: proc(t: ^testing.T) {
	// The Widow holds the knife but wants the Cousin, and the Baron is across.
	g := fixture({.Baron, .None, .Widow, .None}, {.None, .None, .Knife, .None})
	testing.expect(t, !resolve(&g, 0))
	testing.expect(t, g.guests[.Baron].alive)
	// A neighbour is never hit, only the guest across.
	g = fixture({.Baron, .Widow, .None, .None}, {.Knife, .None, .None, .None})
	testing.expect(t, !resolve(&g, 0))
	testing.expect(t, g.guests[.Widow].alive)
}

@(test)
dead_guests_do_not_strike :: proc(t: ^testing.T) {
	g := fixture({.Baron, .None, .Widow, .None}, {.Knife, .None, .None, .None})
	g.guests[.Baron].alive = false
	testing.expect(t, !resolve(&g, 0))
	testing.expect(t, g.guests[.Widow].alive)
}

@(test)
fork_takes_two_wounds :: proc(t: ^testing.T) {
	g := fixture({.Baron, .None, .Widow, .None}, {.Fork, .None, .None, .None})
	resolve(&g, 0)
	testing.expect(t, g.guests[.Widow].alive)
	testing.expect_value(t, g.guests[.Widow].wounds, 1)
	resolve(&g, 0)
	testing.expect(t, !g.guests[.Widow].alive)
}

@(test)
cup_kills_whoever_sits_there_and_is_used_up :: proc(t: ^testing.T) {
	g := fixture({.Baron, .None, .Widow, .None}, {.Poisoned_Cup, .Poisoned_Cup, .None, .None})
	testing.expect(t, resolve(&g, 0))
	testing.expect(t, !g.guests[.Baron].alive)
	testing.expect_value(t, g.lv.tables[0].places[0], Item.None)
	// The cup in front of the empty east seat is still there.
	testing.expect_value(t, g.lv.tables[0].places[1], Item.Poisoned_Cup)
}

@(test)
napkin_takes_the_first_strike_then_is_gone :: proc(t: ^testing.T) {
	g := fixture({.Baron, .None, .Widow, .None}, {.Knife, .None, .Napkin, .None})
	testing.expect(t, resolve(&g, 0))
	testing.expect(t, g.guests[.Widow].alive)
	testing.expect_value(t, g.lv.tables[0].places[2], Item.None)
	testing.expect(t, resolve(&g, 0))
	testing.expect(t, !g.guests[.Widow].alive)
}

@(test)
simultaneous_strikes_all_land :: proc(t: ^testing.T) {
	// The Chef and the Vicar want each other and both hold knives.
	g := fixture({.Chef, .None, .Vicar, .None}, {.Knife, .None, .Knife, .None})
	resolve(&g, 0)
	testing.expect(t, !g.guests[.Chef].alive)
	testing.expect(t, !g.guests[.Vicar].alive)
}

@(test)
hound_bites_the_knife_holder_across :: proc(t: ^testing.T) {
	g := fixture({.Hound, .None, .Baron, .None}, {.None, .None, .Knife, .None})
	testing.expect(t, resolve(&g, 0))
	testing.expect(t, !g.guests[.Baron].alive)
	// No knife across: no bite.
	g = fixture({.Hound, .None, .Baron, .None}, {.Knife, .None, .None, .None})
	testing.expect(t, !resolve(&g, 0))
}

@(test)
marital_aid_does_nothing :: proc(t: ^testing.T) {
	g := fixture({.Baron, .None, .Widow, .None}, {.Marital_Aid, .None, .Marital_Aid, .None})
	testing.expect(t, !resolve(&g, 0))
	testing.expect(t, g.guests[.Baron].alive && g.guests[.Widow].alive)
}

@(test)
cranking_needs_a_crank_underfoot :: proc(t: ^testing.T) {
	g := fixture({.Baron, .None, .Widow, .None}, {.None, .None, .None, .Knife})
	testing.expect(t, !crank(&g))
	testing.expect_value(t, g.turns_used, 0)
	g.player = {12, 9}
	testing.expect(t, crank(&g))
	testing.expect_value(t, g.turns_used, 1)
	testing.expect_value(t, g.outcome, Outcome.Won) // the knife reached the Baron and the Widow died
}

@(test)
being_near_the_table_when_it_goes_off_is_fatal :: proc(t: ^testing.T) {
	g := fixture({.Baron, .None, .Widow, .None}, {.None, .None, .None, .Knife})
	g.lv.tables[0].cranks[0].pos = {9, 4} // two tiles from the table tile
	g.player = {9, 4}
	crank(&g)
	testing.expect_value(t, g.outcome, Outcome.Lost_Caught)
	// A quiet turn nearby is fine.
	g = fixture({.Baron, .None, .Widow, .None}, {.None, .None, .None, .None})
	g.lv.tables[0].cranks[0].pos = {9, 4}
	g.player = {9, 4}
	crank(&g)
	testing.expect_value(t, g.outcome, Outcome.Undecided)
	// Three tiles away is out of sight.
	g = fixture({.Baron, .None, .Widow, .None}, {.None, .None, .None, .Knife})
	g.lv.tables[0].cranks[0].pos = {10, 4}
	g.player = {10, 4}
	crank(&g)
	testing.expect_value(t, g.outcome, Outcome.Won)
}

@(test)
killing_a_guest_who_must_live_loses :: proc(t: ^testing.T) {
	g := fixture({.Baron, .None, .Widow, .None}, {.None, .None, .None, .Knife})
	g.lv.must_die = {.Baron}
	g.lv.must_live = {.Widow}
	g.player = {12, 9}
	crank(&g)
	testing.expect_value(t, g.outcome, Outcome.Lost_Wrong_Death)
}

@(test)
running_out_of_turns_loses_and_stops_play :: proc(t: ^testing.T) {
	g := fixture({.Baron, .None, .Widow, .None}, {.None, .None, .None, .None})
	g.lv.turn_limit = 2
	g.player = {12, 9}
	crank(&g)
	testing.expect_value(t, g.outcome, Outcome.Undecided)
	crank(&g)
	testing.expect_value(t, g.outcome, Outcome.Lost_Out_Of_Turns)
	testing.expect(t, !crank(&g))
	testing.expect(t, !walk(&g, .Left))
}

@(test)
every_level_is_sound :: proc(t: ^testing.T) {
	for lv in LEVELS {
		testing.expect_value(t, level_problem(lv), "")
	}
}

@(test)
every_level_is_solvable_and_its_par_is_the_minimum :: proc(t: ^testing.T) {
	for lv in LEVELS {
		turns, ok := solve(lv)
		testing.expectf(t, ok, "%s cannot be won", lv.name)
		testing.expectf(t, turns == lv.par, "%s: par is %d but the solver found %d", lv.name, lv.par, turns)
		// And it cannot be won in fewer turns than par: shrink the limit by one and it must fail.
		tight := lv
		tight.turn_limit = lv.par - 1
		tight.par = 1
		if tight.turn_limit >= 1 {
			_, fewer := solve(tight)
			testing.expectf(t, !fewer, "%s can be won in under par", lv.name)
		}
	}
}
