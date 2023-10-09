## This [TileMap] extension has a width variable and a method to find rows of matching tiles.
extends TileMapCustom


## Adjust this value to match the width of the play area in the board, then
## adjust the tile_atlas.tres patterns and prime values of custom data layer "group".
@export var drop_width = 9


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
