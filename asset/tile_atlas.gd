## TileAtlas stores aliases for interactive tile_atlases.tres resources.
class_name TileAtlas


const tiles = {
	"SOURCE": 0,
	"EMPTY": Vector2i(-1, -1),
	"BLACK": Vector2i(0, 0),
	"WHITE": Vector2i(1, 0),
	"RAINBOW": Vector2i(2, 0),
	"NEUTRAL": Vector2i(3, 0),
	"OUT": Vector2i(4, 0),
	"OUT_WARNING": Vector2i(5, 0),
	"OTHER": Vector2i(6, 0),
}
const tile_data = {
	"PATHABLE": 0,
}


const path = {
	"SOURCE": 1,
	"EMPTY": Vector2i(-1, -1),
	"NW_CORNER": Vector2i(0, 0),
	"NORTH": Vector2i(1, 0),
	"NE_CORNER": Vector2i(2, 0),
	"WEST": Vector2i(0, 1),
	"CENTER": Vector2i(1, 1),
	"EAST": Vector2i(2, 1),
	"SW_CORNER": Vector2i(0, 2),
	"SOUTH": Vector2i(1, 2),
	"SE_CORNER": Vector2i(2, 2),
	"HORIZONTAL": Vector2i(0, 3),
	"VERTICAL": Vector2i(1, 3),
}
const anim = {
	"SOURCE": 2,
	"EMPTY": Vector2i(-1, -1),
	"PATH_END": Vector2i(0, 0),
}
