## TileAtlas stores constants for atlas sources, tiles, and terrains in tile_atlas/*.tres resources.
class_name TileAtlas


## Tile atlas source IDs.
const SOURCES = {
	"TILES" = 0,
	"PATH" = 1,
	"ANIM_PATH_END" = 2,
	"ORANGE" = 100,
}


## Tiles in the tiles source.
const TILES = {
	"BASE": {
		"BLACK": Vector2i(0, 0),
		"WHITE": Vector2i(1, 0),
		"RAINBOW": Vector2i(2, 0),
		"GRAY": Vector2i(3, 0),
		"GRAY_X": Vector2i(4, 0),
		"GRAY_W_RED_X": Vector2i(5, 0),
		"GRAY_CIRCLE": Vector2i(6, 0),
		"ORANGE": Vector2i(7, 0),
	},
	"ALT_1": {
		"NEUTRAL_SOLID": Vector2i(3, 0),
	},
}


## A self-mapping for TILES.
const TILES_SELF_MAPPING = {
		TILES.BASE.BLACK: TILES.BASE.WHITE,
		TILES.BASE.WHITE: TILES.BASE.BLACK,
}


## The first tile of anim_* tile sources.
const ANIMS = {
	"BASE": {
		"PATH_END": Vector2i(0, 0),
	},
}


## The index and set IDs of terrains.
const TERRAINS = {
	"PATH": {
		"INDEX": 0,
		"SET": 0,
	}
}
