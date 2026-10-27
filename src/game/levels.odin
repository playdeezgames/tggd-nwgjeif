package game

// Hand-made levels, easiest first. Every table sits at (7, 4) unless it says otherwise, with chairs north
// (7,3), east (8,4), south (7,5) and west (6,4); seats and places are in the order north, east, south, west.
// The Baron wants the Widow, the Widow the Cousin, the Cousin the Baron, the Chef and Vicar each other, and the
// Hound bites whoever holds a knife across from it. A weapon in front of a guest strikes the guest across the
// table only if that guest is the one they want. `par` equals the solver's minimum, checked by the tests.
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
				cranks = {
					0 = {pos = {12, 9}, spin = .Clockwise, present = true},
				},
			},
		},
	},
	{
		// A fork only wounds; two wounds kill. Two forks side by side reach the Baron on consecutive turns.
		name = "Forks",
		turn_limit = 2,
		par = 2,
		start = {3, 9},
		table_count = 1,
		must_die = {.Widow},
		tables = {
			0 = {
				pos = {7, 4},
				seats = {.Baron, .None, .Widow, .None},
				places = {.None, .None, .Fork, .Fork},
				cranks = {
					0 = {pos = {13, 10}, spin = .Clockwise, present = true},
				},
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
		// A cup kills whoever it lands in front of, and is then used up. It starts in front of the Cousin; do not bring it round to them.
		name = "Cup",
		turn_limit = 3,
		par = 3,
		start = {3, 9},
		table_count = 1,
		must_die = {.Vicar},
		must_live = {.Cousin},
		tables = {
			0 = {
				pos = {7, 4},
				seats = {.Vicar, .Cousin, .None, .None},
				places = {.None, .Poisoned_Cup, .Knife, .None},
				cranks = {
					0 = {pos = {13, 10}, spin = .Clockwise, present = true},
				},
			},
		},
	},
	{
		// The Hound bites the knife holder across from it. The Chef is across; the knife has to come back round to the Chef's place.
		name = "Hound",
		turn_limit = 4,
		par = 4,
		start = {3, 9},
		table_count = 1,
		must_die = {.Chef},
		must_live = {.Hound},
		tables = {
			0 = {
				pos = {7, 4},
				seats = {.None, .Hound, .None, .Chef},
				places = {.Fork, .None, .None, .Knife},
				cranks = {
					0 = {pos = {13, 10}, spin = .Counter_Clockwise, present = true},
				},
			},
		},
	},
	{
		// The napkin is always in front of the Widow when the knife reaches the Baron, so it takes the first strike and the knife has to come all the way round again.
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
				cranks = {
					0 = {pos = {13, 10}, spin = .Clockwise, present = true},
				},
			},
		},
	},
	{
		// Two tables, two cranks, and the turns add up: one for each.
		name = "Two Tables",
		turn_limit = 2,
		par = 2,
		start = {7, 8},
		table_count = 2,
		must_die = {.Widow, .Vicar},
		tables = {
			0 = {
				pos = {3, 3},
				seats = {.Baron, .None, .Widow, .None},
				places = {.None, .None, .None, .Knife},
				cranks = {0 = {pos = {1, 9}, spin = .Clockwise, present = true}},
			},
			1 = {
				pos = {11, 3},
				seats = {.Vicar, .None, .Chef, .None},
				places = {.None, .Knife, .None, .Marital_Aid},
				cranks = {0 = {pos = {13, 9}, spin = .Clockwise, present = true}},
			},
		},
	},
	{
		// The Cousin wants the Baron, the Baron the Widow, the Widow the Cousin. Here the Widow sits across from the Cousin.
		name = "Ring",
		turn_limit = 4,
		par = 4,
		start = {3, 9},
		table_count = 1,
		must_die = {.Cousin},
		must_live = {.Widow},
		tables = {
			0 = {
				pos = {7, 4},
				seats = {.Cousin, .Baron, .Widow, .None},
				places = {.Fork, .Knife, .Knife, .Napkin},
				cranks = {
					0 = {pos = {13, 10}, spin = .Clockwise, present = true},
				},
			},
		},
	},
	{
		// The fork has to go round the table the long way; use the far crank whenever a strike lands.
		name = "Seen Twice",
		turn_limit = 5,
		par = 5,
		start = {3, 9},
		table_count = 1,
		must_die = {.Chef},
		must_live = {.Vicar},
		tables = {
			0 = {
				pos = {7, 4},
				seats = {.None, .Vicar, .None, .Chef},
				places = {.None, .None, .Fork, .Marital_Aid},
				cranks = {
					0 = {pos = {13, 10}, spin = .Clockwise, present = true},
					1 = {pos = {9, 4}, spin = .Counter_Clockwise, present = true},
				},
			},
		},
	},
	{
		// The cup cannot be stopped from reaching the Cousin on the first turn, and the Vicar is not going to drink it.
		name = "Tour",
		turn_limit = 5,
		par = 5,
		start = {3, 9},
		table_count = 1,
		must_die = {.Vicar},
		must_live = {.Baron},
		tables = {
			0 = {
				pos = {7, 4},
				seats = {.Baron, .Chef, .Cousin, .Vicar},
				places = {.Fork, .Poisoned_Cup, .Marital_Aid, .Marital_Aid},
				cranks = {
					0 = {pos = {13, 10}, spin = .Clockwise, present = true},
				},
			},
		},
	},
	{
		// The Chef wants the Vicar, but a napkin is in the way.
		name = "Grudge Match",
		turn_limit = 7,
		par = 7,
		start = {3, 9},
		table_count = 1,
		must_die = {.Vicar},
		must_live = {.Chef},
		tables = {
			0 = {
				pos = {7, 4},
				seats = {.None, .Vicar, .None, .Chef},
				places = {.Fork, .None, .Napkin, .None},
				cranks = {
					0 = {pos = {13, 10}, spin = .Clockwise, present = true},
				},
			},
		},
	},
	{
		// Everything at once: a cup, two napkins and a fork, and the Chef must survive the dinner.
		name = "Finale",
		turn_limit = 8,
		par = 8,
		start = {3, 9},
		table_count = 1,
		must_die = {.Baron},
		must_live = {.Chef},
		tables = {
			0 = {
				pos = {7, 4},
				seats = {.Baron, .Widow, .Cousin, .Chef},
				places = {.Poisoned_Cup, .Napkin, .Fork, .Napkin},
				cranks = {
					0 = {pos = {13, 10}, spin = .Clockwise, present = true},
				},
			},
		},
	},
}

LEVEL_COUNT :: len(LEVELS)
