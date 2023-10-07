## This [TileMap] extension handles the drawing of tiles contained in the board scene.
extends "res://src/node/tile_map_base.gd"


## Maps layer names to indices.
var layers = {}
## An array of coordinates corresponding to tiles in the path layer.
var path: Array


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in get_layers_count():
		layers[get_layer_name(i)] = i
	path = []


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


## Reports the number of rows of tiles in 'layer' with matching tiles,
## and the coordinates of matched tiles.
## 'full_rows_only': If true, then only rows with a full set of tiles are reported.
## Returns a dictionary mapping:
## 1. tile atlas coordinates to the number of rows cleared,
## 2. Vector2i(-1, -1) to unique row count,
## 3. Vector2i(-1, -2) to an array of matched tile coordinates.
func match_rows(layer: int, full_rows_only = true) -> Dictionary:
	# Maps atlas coordinates to row clears.
	var counts = {Vector2i(-1, -1): 0}
	var matched_tiles = []
	# Maps atlas coordinates to group values.
	var group_values = {}
	var tiles = get_used_cells(layer)
	# Sort tile coordinates from top-to-bottom, then left-to-right.
	tiles.sort_custom(func(a, b): return a.y < b.y or a.y == b.y and a.x < b.x)
	for i in range(0, tiles.size(), drop_width):
		var is_matched = false
		# Sum the group values of tiles in the row.
		var total = 0
		for j in drop_width:
			var tile_atlas_coords = get_cell_atlas_coords(layer, tiles[i + j])
			var tile_data = get_cell_tile_data(layer, tiles[i + j])
			if tile_data:
				var value = tile_data.get_custom_data("group")
				total = total + value
				# Store unique group values.
				if value != 0 and not group_values.has(tile_atlas_coords):
					counts[tile_atlas_coords] = 0
					group_values[tile_atlas_coords] = value
			elif full_rows_only:
				break
		for atlas_coords in group_values.keys():
			# Match total with group values.
			if total % group_values[atlas_coords] == 0:
				is_matched = true
				counts[atlas_coords] = counts[atlas_coords] + 1
		if is_matched:
			counts[Vector2i(-1, -1)] = counts[Vector2i(-1, -1)] + 1
			# Add the row to the array.
			for j in drop_width:
				matched_tiles.append(tiles[i + j])
	counts[Vector2i(-1, -2)] = matched_tiles
	return counts


## Clears the 'tiles' in 'layer'.
func clear_tiles(layer: int, tiles: Array):
	for tile in tiles:
		set_cell(layer, tile, -1)


## Clears the path.
func clear_path() -> void:
	clear_layer(layers.path)
	path.clear()


## Moves tiles in the drop layer to the lowest row without obstruction by solid tiles.
func drop_fast_fall():
	var tiles = get_used_cells(layers.drop)
	# Sort tile coordinates from bottom-to-top, then left-to-right.
	tiles.sort_custom(func(a, b): return a.y > b.y or a.y == b.y and a.x < b.x)
	for i in tiles.size():
		var tile_below = tiles[i] + Vector2i(0, 1)
		# While the tile below is not solid, move the tile down.
		while not tile_is_solid(layers.drop, tile_below) \
				and not tile_is_solid(layers.background, tile_below):
			var atlas_coords = get_cell_atlas_coords(layers.drop, tiles[i], false)
			set_cell(layers.drop, tiles[i], -1)
			tiles[i] = tile_below
			set_cell(layers.drop, tiles[i], atlas.SOURCES.TILES, atlas_coords)
			tile_below = tile_below + Vector2i(0, 1)


## Adds a tile at 'coords' to the path layer if it is a valid addition.
## Returns true if the operation is successful.
func path_append(coords: Vector2i) -> bool:
	if path_can_add(coords):
		path.append(coords)
		_update_path_layer()
		return true
	return false


## Returns true if the tile at 'coords' can be added to the path.
func path_can_add(coords: Vector2i) -> bool:
	if not tile_is_pathable(layers.background, coords):
		return false
	elif path.is_empty():
		return true
	elif path.has(coords):
		return false
	else:
		# Check if the tile shares a side with the end of the path.
		return coords.x == path[-1].x and abs(path[-1].y - coords.y) == 1 \
				or coords.y == path[-1].y and abs(path[-1].x - coords.x) == 1


## Returns the coordinates of the tile at 'index', or Vector2i(-1, -1) if the index is invalid.
func path_get(index: int) -> Vector2i:
	if index < -path.size() or index >= path.size():
		return Vector2i(-1, -1)
	return path[index]


## Returns true if the path layer contains 'coords'.
func path_has(coords: Vector2i) -> bool:
	return path.has(coords)


## Returns true if the path layer is empty.
func path_is_empty() -> bool:
	return path.size() == 0


## Truncates the path such that it ends at 'index'.
func truncate_path(index: int):
	if index < -path.size() or index >= path.size():
		return
	# Erase cells from the path layer.
	for i in path.slice(index + 1).size():
			set_cell(2, path[i + index + 1], -1)
	# Truncate the path array.
	path = path.slice(0, index + 1)
	_update_path_layer()


## Updates the drawing of the path layer.
func _update_path_layer() -> void:
	set_cells_terrain_path(layers.path, path, atlas.TERRAINS.PATH.SET, atlas.TERRAINS.PATH.INDEX)
	# Set the last tile to a special, animated tile.
	set_cell(layers.path, path[-1], atlas.SOURCES.ANIM_PATH_END, atlas.ANIMS.BASE.PATH_END)
