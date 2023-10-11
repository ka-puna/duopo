## TileAtlas stores constants for atlas sources, and tiles in tile_atlas/*.tres resources.
class_name TileAtlas


## The source_ids for tile atlases.
const SOURCES = {
	"TILES" = 0,
	"PATH" = 1,
	"ANIM_PATH_END" = 2,
	"ORANGE" = 100,
}


## Tiles in source "tiles".
const TILES = {
	"BASE": {
		"BLACK": Vector2i(0, 0),
		"WHITE": Vector2i(1, 0),
		"RAINBOW": Vector2i(2, 0),
		"GRAY": Vector2i(3, 0),
		"GRAY_X": Vector2i(4, 0),
		"GRAY_RED_X": Vector2i(5, 0),
		"GRAY_CIRCLE": Vector2i(6, 0),
		"ORANGE": Vector2i(7, 0),
	},
	"ALT_1": {
		"GRAY_SOLID": Vector2i(3, 0),
	},
}


## A self-mapping for source "tiles".
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
