## TileMapCommand creates Callable functions for its associated tile_map.gd instance.


## The target instance.
var tile_map: TileMap


func _init(init_tile_map: TileMap):
	tile_map = init_tile_map


## Returns a Callable:
## Changes drop layer tiles according to a dictionary mapping the set of
## atlas coordinates to itself.
func get_func_self_map_layer() -> Callable:
	var callable = func(layer: int, self_map: Dictionary):
		for coords in tile_map.path:
			var old_atlas = tile_map.get_cell_atlas_coords(layer, coords)
			if old_atlas in self_map:
				tile_map.set_cell(layer, coords, \
						tile_map.atlas.SOURCES.TILES, self_map[old_atlas])
	return callable

## Returns a Callable:
## Moves tiles in 'layer' to the lowest row without obstruction by solid tiles.
func get_func_drop_layer() -> Callable:
	var callable = func(layer: int):
		var tiles = tile_map.get_used_cells(layer)
		# Sort tile coordinates from bottom-to-top, then left-to-right.
		tiles.sort_custom(func(a, b): return a.y > b.y or a.y == b.y and a.x < b.x)
		for i in tiles.size():
			var tile_below = tiles[i] + Vector2i(0, 1)
			# While the tile below is not solid, move the tile down.
			while not tile_map.tile_is_solid(layer, tile_below) \
					and not tile_map.tile_is_solid(tile_map.layers.background, tile_below):
				var atlas_coords = tile_map.get_cell_atlas_coords(layer, tiles[i], false)
				tile_map.set_cell(layer, tiles[i], -1)
				tiles[i] = tile_below
				tile_map.set_cell(layer, tiles[i], tile_map.atlas.SOURCES.TILES, atlas_coords)
				tile_below = tile_below + Vector2i(0, 1)
	return callable