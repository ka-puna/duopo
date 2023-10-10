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
## Moves tiles in 'layer' to the lowest row without obstruction by solid tiles.
## Assumes that the tile map has a layer "background".
func get_drop() -> Callable:
	var drop = func(layer: int):
		var tiles = tile_map.get_used_cells(layer)
		# Sort tiles from bottom-to-top, then left-to-right.
		tiles.sort_custom(func(a, b): return a.y > b.y or a.y == b.y and a.x < b.x)
		for i in tiles.size():
			var tile_below = tiles[i] + Vector2i(0, 1)
			# While the tile below is not solid, move the tile down.
			while not tile_map.tile_is_solid(layer, tile_below) \
					and not tile_map.tile_is_solid(tile_map.layers.background, tile_below):
				var tile_type = tile_map.get_cell_atlas_coords(layer, tiles[i], false)
				tile_map.set_cell(layer, tiles[i], -1)
				tiles[i] = tile_below
				tile_map.set_cell(layer, tiles[i], tile_map.atlas.SOURCES.TILES, tile_type)
				tile_below = tile_below + Vector2i(0, 1)
	return drop
