## Path maintains an array of connected tiles.
class_name Path


signal updated()


var path = []
var terrain_set: int
var terrain_index: int


## Adds 'tile' to the path layer.
func append(tile: Vector2i) -> void:
	path.append(tile)
	updated.emit()


## Clears the path.
func clear() -> void:
	path.clear()
	updated.emit()


## Returns true if 'tile' can be appended to the path.
func can_append(tile: Vector2i) -> bool:
	if path.is_empty():
		return true
	elif path.has(tile):
		return false
	else:
		# Return true if the tile shares a side with the end of the path.
		return tile.x == path[-1].x and abs(path[-1].y - tile.y) == 1 \
				or tile.y == path[-1].y and abs(path[-1].x - tile.x) == 1


## Returns the path index of a tile at 'tile', or -1 if the index is invalid.
func find(tile: Vector2i) -> int:
	return path.find(tile)


## Returns the coordinates of the tile at 'index', or Vector2i(-1, -1) if the index is invalid.
func get_index(index: int) -> Vector2i:
	if index < -path.size() or index >= path.size():
		return Vector2i(-1, -1)
	return path[index]


## Returns the array of tile coordinates for tiles in the path.
func get_tiles() -> Array:
	return path


## Returns true if the path layer contains 'tile'.
func has(tile: Vector2i) -> bool:
	return path.has(tile)


## Returns true if the path layer is empty.
func is_empty() -> bool:
	return path.is_empty()


## Truncates the path such that it ends at 'index'.
func truncate(index: int):
	if index < -path.size() or index >= path.size():
		return
	# Report cells for deletion.
	var removed = []
	for i in path.slice(index + 1).size():
			removed.append(path[i + index + 1])
	# Truncate the path array.
	path = path.slice(0, index + 1)
	updated.emit()
