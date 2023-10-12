## TileMapCommand creates Callable functions for [TileMapCustom].
class_name TileMapCommand


## The executing object.
var tile_map: TileMapCustom


func _init(init_tile_map: TileMapCustom):
	tile_map = init_tile_map


## Returns a Callable:
## Moves tiles in 'layers'[0] to the lowest row without obstruction by solid tiles.
##		'layers': An array of layers to check for tiles.
func get_drop() -> Callable:
	var drop = func(layers: Array):
		var tiles = tile_map.get_used_cells(layers[0])
		# Sort tiles from bottom-to-top, then left-to-right.
		tiles.sort_custom(func(a, b): return a.y > b.y or a.y == b.y and a.x < b.x)
		for i in tiles.size():
			var tile_below = tiles[i] + Vector2i(0, 1)
			var is_blocked = false
			for layer in layers:
				if tile_map.tile_is_solid(layer, tile_below):
					is_blocked = true
					break
			while not is_blocked:
				# Move the tile down.
				var tile_type = tile_map.get_cell_atlas_coords(layers[0], tiles[i], false)
				tile_map.erase_cell(layers[0], tiles[i])
				tiles[i] = tile_below
				tile_map.set_cell(layers[0], tiles[i], tile_map.atlas.SOURCES.TILES, tile_type)
				# Update while-loop condition.
				tile_below = tile_below + Vector2i(0, 1)
				for layer in layers:
					if tile_map.tile_is_solid(layer, tile_below):
						is_blocked = true
						break
	return drop


## Returns a Callable:
## Matches rows of tiles in 'layer' with 'width', according to ''data_layer''.
## Returns a dictionary mapping:
## 1. tile atlas coordinates to the number of rows matched.
## 2. Vector2i(-1, -1) to unique row count.
## 3. Vector2i(-1, -2) to an array of matched tile coordinates.
func get_match_rows(data_layer: String) -> Callable:
	var match_rows = Callable()
	if data_layer == "group":
		match_rows = func(layer: int, width: int):
			var counts = {Vector2i(-1, -1): 0}
			var matched_tiles = []
			# Maps atlas coordinates to group values.
			var group_values = {}
			var tiles = tile_map.get_used_cells(layer)
			# Sort tile coordinates from top-to-bottom, then left-to-right.
			tiles.sort_custom(func(a, b): return a.y < b.y or a.y == b.y and a.x < b.x)
			for i in range(0, tiles.size(), width):
				var is_matched = false
				# Sum the group values of tiles in the row.
				var total = 0
				for j in width:
					var tile_type = tile_map.get_cell_atlas_coords(layer, tiles[i + j])
					var tile_data = tile_map.get_cell_tile_data(layer, tiles[i + j])
					if tile_data:
						var value = tile_data.get_custom_data("group")
						total = total + value
						# Store unique group values.
						if value != 0 and not group_values.has(tile_type):
							counts[tile_type] = 0
							group_values[tile_type] = value
					else:
						total = 0
						break
				if total <= 0:
					continue
				for tile_type in group_values.keys():
					# Match total with group values.
					if total % group_values[tile_type] == 0:
						is_matched = true
						counts[tile_type] = counts[tile_type] + 1
				if is_matched:
					counts[Vector2i(-1, -1)] = counts[Vector2i(-1, -1)] + 1
					# Add the row to the array.
					for j in width:
						matched_tiles.append(tiles[i + j])
			counts[Vector2i(-1, -2)] = matched_tiles
			return counts
	return match_rows


## Returns a Callable:
## Changes tiles in the path and 'layer' according to a ''self_map'' dictionary
## mapping the set of atlas coordinates to itself.
func get_path_map(self_map: Dictionary) -> Callable:
	var path_map = func(layer: int):
		for tile in tile_map.path:
			var tile_type = tile_map.get_cell_atlas_coords(layer, tile)
			if tile_type in self_map:
				tile_map.set_cell(layer, tile, \
						tile_map.atlas.SOURCES.TILES, self_map[tile_type])
	return path_map
