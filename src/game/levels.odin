package game

// Hand-made levels. Table at (7, 4): chairs north (7,3), east (8,4), south (7,5), west (6,4); seats and
// places are in the order north, east, south, west. Baron wants the Widow, so a knife in front of the Baron
// kills a Widow across the table. `par` is checked against the solver by the tests.
LEVELS := [?]Level {
	{
		// A turn moves the knife from the empty west place to the Baron. The Marital Aid rides along, embarrassingly.
		name = "Soup",
		turn_limit = 2,
		par = 1,
		start = {3, 9},
		table_count = 1,
		must_die = {.Widow},
		tables = {
			0 = {
				pos = {7, 4},
				seats = {.Baron, .None, .Widow, .None},
				places = {.None, .Marital_Aid, .None, .Knife},
				cranks = {0 = {pos = {12, 9}, spin = .Clockwise, present = true}},
			},
		},
	},
	{
		// The near crank gets the knife to the Baron in one turn but you would be seen; the far one needs three.
		name = "Seen",
		turn_limit = 3,
		par = 3,
		start = {3, 9},
		table_count = 1,
		must_die = {.Widow},
		tables = {
			0 = {
				pos = {7, 4},
				seats = {.Baron, .None, .Widow, .None},
				places = {.None, .Knife, .None, .None},
				cranks = {
					0 = {pos = {9, 4}, spin = .Counter_Clockwise, present = true},
					1 = {pos = {13, 10}, spin = .Clockwise, present = true},
				},
			},
		},
	},
	{
		// The napkin always sits in front of the Widow when the knife reaches the Baron, so it eats the first
		// strike and the knife has to come all the way round again.
		name = "Napkin",
		turn_limit = 5,
		par = 5,
		start = {3, 9},
		table_count = 1,
		must_die = {.Widow},
		tables = {
			0 = {
				pos = {7, 4},
				seats = {.Baron, .None, .Widow, .None},
				places = {.None, .Napkin, .None, .Knife},
				cranks = {0 = {pos = {13, 10}, spin = .Clockwise, present = true}},
			},
		},
	},
}

LEVEL_COUNT :: len(LEVELS)
