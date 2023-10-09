## The base class for custom tile_maps using the tile_atlas.res resource.
extends TileMap


## Aliases for each integer return status.
enum RETURN_STATUS { SUCCESS = 0, INVALID_ARGS = 1, BLOCKED = 2 }
## Maps layer names to indices.
var layers = {}
var atlas = TileAtlas.new()

func _ready():
	for i in get_layers_count():
		layers[get_layer_name(i)] = i


## Adds the pattern associated with 'pattern_id' to 'layer' at or above the tile map origin.
## Returns a RETURN_STATUS integer value.
## { SUCCESS = 0, INVALID_ARGS = 1, BLOCKED = 2 }
func add_pattern(layer: int, pattern_id: int) -> int:
	if pattern_id < 0 or pattern_id > tile_set.get_patterns_count() - 1:
		return RETURN_STATUS.INVALID_ARGS
	## Check for obstruction.
	if get_cell_tile_data(layer, Vector2i(0, 0)):
		return RETURN_STATUS.BLOCKED
	var pattern = tile_set.get_pattern(pattern_id)
	var height = pattern.get_size().y
	set_pattern(layer, Vector2i(0, 1 - height), pattern)
	return RETURN_STATUS.SUCCESS


## Clears the 'tiles' in 'layer'.
func clear_tiles(layer: int, tiles: Array):
	for tile in tiles:
		set_cell(layer, tile, -1)


## Returns true if the tile at 'coords' in layer' is pathable.
func tile_is_pathable(layer: int, coords: Vector2i) -> bool:
	var tile_data = get_cell_tile_data(layer, coords)
	return tile_data and tile_data.get_custom_data("pathable")


## Returns true if the tile in 'layer' at 'coords' is solid.
func tile_is_solid(layer: int, coords: Vector2i) -> bool:
	var tile_data = get_cell_tile_data(layer, coords)
	return tile_data and tile_data.get_custom_data("solid")
