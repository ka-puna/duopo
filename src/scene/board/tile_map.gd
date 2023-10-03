## This [TileMap] extension handles the drawing of tiles contained in the board scene.
extends TileMap

## Aliases for each integer return status.
enum RETURN_STATUS { SUCCESS = 0, BLOCKED = 1, INVALID_ARGS = 2 }
## Aliases for each layer's integer id.
enum LAYER { BACKGROUND, DROP, PATH }
var atlas = TileAtlas.new()
## An array of coordinates corresponding to tiles in the path layer.
var path: Array


# Called when the node enters the scene tree for the first time.
func _ready():
	path = []


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


## Clears the path.
func clear_path() -> void:
	clear_layer(LAYER.PATH)
	path.clear()


## Adds the pattern associated with 'pattern_id' to the drop layer at or above the tile map origin.
## Returns a RETURN_STATUS integer value.
## { SUCCESS = 0, BLOCKED = 1, INVALID_ARGS = 2}
func drop_add_pattern(pattern_id: int) -> int:
	if pattern_id < 0 or pattern_id > tile_set.get_patterns_count() - 1:
		return RETURN_STATUS.INVALID_ARGS
	## Check for obstruction.
	if get_cell_tile_data(LAYER.DROP, Vector2i(0, 0)):
		return RETURN_STATUS.BLOCKED
	var pattern = tile_set.get_pattern(pattern_id)
	var height = pattern.get_size().y
	set_pattern(LAYER.DROP, Vector2i(0, 1 - height), pattern)
	return RETURN_STATUS.SUCCESS


## Moves tiles in the drop layer to the lowest row without obstruction by solid tiles.
func drop_fast_fall():
	var tiles = get_used_cells(LAYER.DROP)
	# Sort tile coordinates from top-to-bottom, then left-to-right.
	tiles.sort_custom(func(a, b): return a.y > b.y or a.y == b.y and a.x < b.x)
	for i in range(tiles.size()):
		var tile_below = tiles[i] + Vector2i(0, 1)
		# While the tile below is not solid, move the tile down.
		while not tile_is_solid(LAYER.DROP, tile_below) \
				and not tile_is_solid(LAYER.BACKGROUND, tile_below):
			var atlas_coords = get_cell_atlas_coords(LAYER.DROP, tiles[i], false)
			set_cell(LAYER.DROP, tiles[i], -1)
			tiles[i] = tile_below
			set_cell(LAYER.DROP, tiles[i], atlas.tiles.SOURCE, atlas_coords)
			tile_below = tile_below + Vector2i(0, 1)


## Adds a tile at 'coords' to the path layer if it is a valid addition.
## Returns true if the operation is successful.
func path_append(coords: Vector2i) -> bool:
	if tile_is_pathable(coords):
		path.append(coords)
		_update_path_layer()
		return true
	return false


## Returns true if the tile at coords is in bounds.
func tile_is_in_bounds(coords: Vector2i) -> bool:
	var tile_data = get_cell_tile_data(LAYER.BACKGROUND, coords)
	return tile_data and tile_data.get_custom_data_by_layer_id(atlas.tile_data.PATHABLE)


## Returns true if the tile in 'layer' at 'coords' is solid.
func tile_is_solid(layer: int, coords: Vector2i) -> bool:
	var tile_data = get_cell_tile_data(layer, coords)
	return tile_data and tile_data.get_custom_data_by_layer_id(atlas.tile_data.SOLID)


## Truncates the path such that it ends at 'index'.
func truncate_path(index: int):
	if not index in range(path.size()):
		return
	# Erase cells from the path layer.
	for i in path.slice(index + 1).size():
			set_cell(2, path[i + index + 1], -1)
	# Truncate the path array.
	path = path.slice(0, index + 1)
	_update_path_layer()


## Returns true if the tile at 'coords' can be added to the path.
func tile_is_pathable(coords: Vector2i) -> bool:
	if not tile_is_in_bounds(coords):
		return false
	elif path.is_empty():
		return true
	elif path.has(coords):
		return false
	else:
		# Check if the tile shares a side with the end of the path.
		return coords.x == path[-1].x and abs(path[-1].y - coords.y) == 1 \
				or coords.y == path[-1].y and abs(path[-1].x - coords.x) == 1


## Updates the drawing of the path layer.
func _update_path_layer() -> void:
	set_cells_terrain_path(LAYER.PATH, path, atlas.terrains.PATH.SET, atlas.terrains.PATH.INDEX)
	# Set the last tile to a special, animated tile.
	set_cell(LAYER.PATH, path[-1], atlas.anim.SOURCE, atlas.anim.PATH_END)
