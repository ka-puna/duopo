## TileAtlas stores constants for atlas sources, and tiles in tile_atlas/*.tres resources.
class_name TileAtlas


## The first tile of anim_* tile sources.
const ANIMS = {
	"BASE": {
		"PATH_END": Vector2i(0, 0),
		"TILE_SELECT": Vector2i(0, 0),
	},
}


## Sampling table for pattern subsets.
const SAMPLE = [
	# 0, 5: 0, 19: 3-height patterns.
	[1, 0, 1], [0.5, 2, 3], [1, 4, 5, 6, 7], [1, 8, 9, 10, 11], [1, 12, 13, 14, 15], [1, 16, 17, 18, 19],
	# 6, 9: 20, 33: 2-height patterns.
	[1, 20, 21], [1, 22, 23, 24, 25], [1, 26, 27, 28, 29], [1, 30, 31, 32, 33],
	# 10, 13: 34, 43: 1-height patterns.
	[0.5, 34, 35], [1, 36, 37, 38, 39], [1, 40, 41], [0.5, 42, 43],
	# 14, 18: 44, 55: 4-height patterns.
	[0.5, 44, 45], [0.25, 46, 47, 48, 49], [0.5, 50, 51], [0.5, 52, 53], [0.25, 54, 55],
]


## The source_ids for tile atlases.
const SOURCES = {
	"TILES" = 0,
	"PATH" = 1,
	"ANIM_PATH_END" = 2,
	"ANIM_TILE_SELECT" = 3,
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