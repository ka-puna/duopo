## TileMapCommand creates Callable functions for its associated tile_map.gd instance.


## The target instance.
var tile_map: TileMap


func _init(init_tile_map: TileMap):
	tile_map = init_tile_map


## Returns a Callable that changes drop layer tiles according to a dictionary
## mapping the set of atlas coordinates to itself.
func get_drop_layer_self_map() -> Callable:
	var callable = func(self_map):
		for coords in tile_map.path:
			var old_atlas = tile_map.get_cell_atlas_coords(tile_map.LAYER.DROP, coords)
			if old_atlas in self_map:
				tile_map.set_cell(tile_map.LAYER.DROP, coords, \
						tile_map.atlas.SOURCES.TILES, self_map[old_atlas])
	return callable
