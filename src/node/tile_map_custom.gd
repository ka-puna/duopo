## The base class for custom [TileMap] subclasses which use a tile_atlas/*.tres resource.
class_name TileMapCustom
extends TileMap


## Match entries with terrains in the TileMap.Terrains editor.
@export var TERRAINS: Dictionary
enum RETURN_STATUS { SUCCESS = 0, INVALID_ARGS = 1, BLOCKED = 2 }
## Maps layer names to indices.
var layers = {}
var atlas = TileAtlas.new()

func _ready():
	for i in get_layers_count():
		layers[get_layer_name(i)] = i


## Adds the pattern associated with 'pattern_id' to 'layer' at or above the tile map origin.
## Returns a [enum TileMapCustom.RETURN_STATUS] integer value.
func add_pattern(layer: int, pattern_id: int) -> int:
	if pattern_id < 0 or pattern_id > tile_set.get_patterns_count() - 1:
		return RETURN_STATUS.INVALID_ARGS
	## If a tile exists at the tile map origin.
	if get_cell_tile_data(layer, Vector2i(0, 0)):
		return RETURN_STATUS.BLOCKED
	var pattern = tile_set.get_pattern(pattern_id)
	var height = pattern.get_size().y
	set_pattern(layer, Vector2i(0, 1 - height), pattern)
	return RETURN_STATUS.SUCCESS


## Clears the 'tiles' in 'layer'.
func clear_tiles(layer: int, tiles: Array):
	for tile in tiles:
		erase_cell(layer, tile)


## Returns custom 'data' from 'tile' in 'layer', or null if it does not exist.
func tile_get_data(layer: int, tile: Vector2i, data: String):
	var tile_data = get_cell_tile_data(layer, tile)
	if tile_data:
		return tile_data.get_custom_data(data)
	return null
