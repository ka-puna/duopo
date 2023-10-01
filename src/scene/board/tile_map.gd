## This [TileMap] extension handles the drawing of tiles contained in the board scene.
extends TileMap


## Aliases for each layer's integer id.
enum LAYER { BACKGROUND, DROP, PATH }
## The local coordinates of the top-left tile of the in-bounds region.
@export var inbound_top_left = Vector2i(0, 8)
## The local coordinates of the bottom-right tile of the in-bounds region.
@export var inbound_bottom_right = Vector2i(10, 18)
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
	self.clear_layer(LAYER.PATH)
	path.clear()


## Adds 'coords' to the path layer.
## Returns true if the operation is successful.
func path_append(coords: Vector2i) -> bool:
	if tile_is_pathable(coords):
		path.append(coords)
		_update_path_layer()
		return true
	return false


## Returns true if 'coords' is in bounds.
func tile_is_in_bounds(coords: Vector2i) -> bool:
	return coords.x >= inbound_top_left.x and coords.x <= inbound_bottom_right.x \
			and coords.y >= inbound_top_left.y and coords.y <= inbound_bottom_right.y


## Truncates the path such that it ends at 'index'.
func truncate_path(index: int):
	if not index in range(path.size()):
		return
	# Erase tiles from the path layer.
	for i in path.slice(index + 1).size():
			self.set_cell(2, path[i + index + 1], -1)
	# Truncate the path array.
	path = path.slice(0, index + 1)
	_update_path_layer()


## Returns true if 'coords' can be added to the path.
func tile_is_pathable(coords: Vector2i) -> bool:
	if not tile_is_in_bounds(coords):
		return false
	elif path.is_empty():
		return true
	elif path.has(coords):
		return false
	else:
		return coords.x == path[-1].x and abs(path[-1].y - coords.y) == 1 \
				or coords.y == path[-1].y and abs(path[-1].x - coords.x) == 1


## Updates the drawing of the last two tiles in the path layer.
func _update_path_layer() -> void:
	if not path.is_empty():
		if path.size() > 1:
			# Use the path's direction to determine the second-to-last tile's atlas coordinates.
			var atlas_coords = Vector2i(-1, -1)
			var to_last = Vector2i(path[-1].x - path[-2].x, path[-1].y - path[-2].y)
			if path.size() > 2:
				var to_second_last = Vector2i(path[-2].x - path[-3].x, path[-2].y - path[-3].y)
				match to_second_last:
					Vector2i(0, -1):
						match to_last:
							Vector2i(-1, 0):
								atlas_coords = atlas.path.SW_CORNER
							Vector2i(1, 0):
								atlas_coords = atlas.path.SE_CORNER
							_:
								atlas_coords = atlas.path.VERTICAL
					Vector2i(-1, 0):
						match to_last:
							Vector2i(0, -1):
								atlas_coords = atlas.path.NE_CORNER
							Vector2i(0, 1):
								atlas_coords = atlas.path.SE_CORNER
							_:
								atlas_coords = atlas.path.HORIZONTAL
					Vector2i(1, 0):
						match to_last:
							Vector2i(0, -1):
								atlas_coords = atlas.path.NW_CORNER
							Vector2i(0, 1):
								atlas_coords = atlas.path.SW_CORNER
							_:
								atlas_coords = atlas.path.HORIZONTAL
					Vector2i(0, 1):
						match to_last:
							Vector2i(-1, 0):
								atlas_coords = atlas.path.NW_CORNER
							Vector2i(1, 0):
								atlas_coords = atlas.path.NE_CORNER
							_:
								atlas_coords = atlas.path.VERTICAL
					_:
						printerr("Invalid 3rd-to-2nd-last difference vector: ", to_second_last)
			else:
				match to_last:
					Vector2i(0, -1):
						atlas_coords = atlas.path.NORTH
					Vector2i(-1, 0):
						atlas_coords = atlas.path.WEST
					Vector2i(1, 0):
						atlas_coords = atlas.path.EAST
					Vector2i(0, 1):
						atlas_coords = atlas.path.SOUTH
					_:
						printerr("Invalid 2nd-to-last difference vector: ", to_last)

			self.set_cell(2, path[-2], atlas.path.SOURCE, atlas_coords)

		self.set_cell(2, path[-1], atlas.anim.SOURCE, atlas.anim.PATH_END)
