## This [TileMap] subclass maintains a path of connected tiles.
class_name TileMapPathable
extends "res://src/node/tile_map.gd"


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


## Clears the path.
func clear_path() -> void:
	clear_layer(layers.path)
	path.clear()


## Adds a tile at 'coords' to the path layer.
func path_append(coords: Vector2i) -> void:
	path.append(coords)
	_update_path_layer()


## Returns true if the tile at 'coords' can be appended to the path.
func path_can_append(coords: Vector2i) -> bool:
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


## Returns the path index of a tile at 'coords', or -1 if the index is invalid.
func path_find(coords: Vector2i) -> int:
	return path.find(coords)


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
