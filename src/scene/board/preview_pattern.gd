## Displays a pattern with a reverse-progress bar overlay.
class_name PreviewPattern
extends Control


## The y position of the tile_map, relative to the PreviewPattern node.
## Adjust it according to the maximum height of the pattern.
@export var tile_map_y_position: float = 0.0
@onready var progress_bar: ProgressBar = $ProgressBar
var pattern_id: int = -1: set = set_pattern_id, get = get_pattern_id
var tile_map: TileMapCustom


# Called when the node enters the scene tree for the first time.
func _ready():
	tile_map = $tile_map
	tile_map_set_y_position(tile_map_y_position)


## Set the PreviewPattern's principal values.
func init(tile_set: TileSet, progress_max_value: float):
	tile_map.tile_set = tile_set
	progress_bar_set_max_value(progress_max_value)


## Returns the id of the displayed pattern, or -1 if it does not exist.
func get_pattern_id():
	return pattern_id


## Sets the progress bar's maxmimum value to 'value'.
func progress_bar_set_max_value(value: float):
	progress_bar.set_max(value)


## Sets the progress bar's value to its maximum value - 'value'.
func progress_bar_set_value_inverse(value: float):
	progress_bar.set_value(progress_bar.max_value - value)


## Set the id of the displayed pattern to 'id'.
func set_pattern_id(id: int):
	var previous_pattern_id = pattern_id
	tile_map.clear()
	if id == -1 or tile_map.add_pattern(0, id) == tile_map.RETURN_STATUS.SUCCESS:
		pattern_id = id
	else:
		tile_map.add_pattern(0, previous_pattern_id)


## Sets the tile map's relative y-position to 'y'.
func tile_map_set_y_position(y: float):
	tile_map.position = (Vector2(tile_map.get_position().x, y))
	tile_map_y_position = y
