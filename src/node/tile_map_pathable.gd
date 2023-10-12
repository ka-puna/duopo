## This [TileMapCustom] subclass maintains a path of connected tiles.
class_name TileMapPathable
extends TileMapCustom


## An array of coordinates corresponding to tiles in the path layer.
@onready var path = []
const TERRAINS = {
	"PATH": {
		"SET": 0,
		"INDEX": 0,
	},
}


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in get_layers_count():
		layers[get_layer_name(i)] = i


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


## Clears the path.
func clear_path() -> void:
	clear_layer(layers.path)
	path.clear()


## Adds 'tile' to the path layer.
func path_append(tile: Vector2i) -> void:
	path.append(tile)
	_update_path_layer()


## Returns true if tile' can be appended to the path.
func path_can_append(tile: Vector2i) -> bool:
	if not tile_is_pathable(layers.background, tile):
		return false
	elif path.is_empty():
		return true
	elif path.has(tile):
		return false
	else:
		# Return true if the tile shares a side with the end of the path.
		return tile.x == path[-1].x and abs(path[-1].y - tile.y) == 1 \
				or tile.y == path[-1].y and abs(path[-1].x - tile.x) == 1


## Returns the path index of a tile at 'tile', or -1 if the index is invalid.
func path_find(tile: Vector2i) -> int:
	return path.find(tile)


## Returns the coordinates of the tile at 'index', or Vector2i(-1, -1) if the index is invalid.
func path_get(index: int) -> Vector2i:
	if index < -path.size() or index >= path.size():
		return Vector2i(-1, -1)
	return path[index]


## Returns true if the path layer contains 'tile'.
func path_has(tile: Vector2i) -> bool:
	return path.has(tile)


## Returns true if the path layer is empty.
func path_is_empty() -> bool:
	return path.size() == 0


## Truncates the path such that it ends at 'index'.
func truncate_path(index: int):
	if index < -path.size() or index >= path.size():
		return
	# Erase cells from the path layer.
	for i in path.slice(index + 1).size():
			erase_cell(2, path[i + index + 1])
	# Truncate the path array.
	path = path.slice(0, index + 1)
	_update_path_layer()


## Updates the drawing of the path layer.
func _update_path_layer() -> void:
	set_cells_terrain_path(layers.path, path, TERRAINS.PATH.SET, TERRAINS.PATH.INDEX)
	# Set the last tile to a special, animated tile.
	set_cell(layers.path, path[-1], atlas.SOURCES.ANIM_PATH_END, atlas.ANIMS.BASE.PATH_END)
