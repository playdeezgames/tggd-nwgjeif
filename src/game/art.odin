package game

// Order must match the sprite order in assets/art/world.json (see tools/gen_atlas.py).
Sprite :: enum i32 {
	Player,
	Baron,
	Widow,
	Cousin,
	Chef,
	Vicar,
	Hound,
	Dead,
	Chair,
	Table,
	Knife,
	Fork,
	Cup,
	Napkin,
	Aid,
	Crank_Cw,
	Crank_Ccw,
	Wound,
}

SPRITE_SIZE :: 16

// Guest_Id.None and Item.None have no picture; the Chair and Table sprites stand in and are never drawn for them.
GUEST_SPRITES := [Guest_Id]Sprite {
	.None   = .Chair,
	.Baron  = .Baron,
	.Widow  = .Widow,
	.Cousin = .Cousin,
	.Chef   = .Chef,
	.Vicar  = .Vicar,
	.Hound  = .Hound,
}

// Item sprites are 8x8 pictures centred in a 16x16 cell, so four of them fit round one table tile.
ITEM_SPRITES := [Item]Sprite {
	.None         = .Table,
	.Knife        = .Knife,
	.Fork         = .Fork,
	.Poisoned_Cup = .Cup,
	.Napkin       = .Napkin,
	.Marital_Aid  = .Aid,
}

// Order must match SOUND_FILES in web/index.html (assets/sfx/<name>.wav).
Sound :: enum i32 {
	Crank,
	Strike,
	Drink,
	Saved,
	Caught,
	Won,
	Lost,
}
