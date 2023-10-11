## TileMapCommand creates Callable functions for [TileMapCustom].


## The executing object.
var tile_map: TileMapCustom


func _init(init_tile_map: TileMapCustom):
	tile_map = init_tile_map


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


## Returns a Callable:
## Moves tiles in 'layers'[0] to the lowest row without obstruction by solid tiles.
##		'layers': An array of layer indices.
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
				tile_map.set_cell(layers[0], tiles[i], -1)
				tiles[i] = tile_below
				tile_map.set_cell(layers[0], tiles[i], tile_map.atlas.SOURCES.TILES, tile_type)
				# Update while-loop condition.
				tile_below = tile_below + Vector2i(0, 1)
				for layer in layers:
					if tile_map.tile_is_solid(layer, tile_below):
						is_blocked = true
						break
	return drop
