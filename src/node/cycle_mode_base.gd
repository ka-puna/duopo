## The base script for a game mode scene where patterns are dropped based on a cycling value.
class_name CycleModeBase
extends Control


enum ACTION_STATE {JUST_PRESSED, PRESSED, JUST_RELEASED}
enum DIRECTION {LEFT = 0, RIGHT = 1, UP = 2, DOWN = 3}
## The position of the selected tile. Set its intial position in the editor.
@export var tile_selected: Vector2i
## The period between drops in units such as seconds.
@export var cycle_period: float = 10.0: set = set_cycle_period
@onready var cycle_value: float = 0.0: set = set_cycle_value
var actions: Array[StringName]
var board: TileMapCustom
var layers: Dictionary
var tile_set: TileSet
var preview: PreviewPattern

var drop: Callable


# Called when the node enters the scene tree for the first time.
func _ready():
	layers = board.layers
	tile_set = board.tile_set
	board.update_terrains()
	preview.init(tile_set, cycle_period)
	var pattern = get_new_pattern()
	preview.set_pattern_id(pattern)
	update_tile_selected(tile_selected)
	update_actions()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Exclude out-of-bounds mouse actions.
	if Input.get_mouse_button_mask() != 0:
		var mouse_tile = board.local_to_map(board.get_local_mouse_position())
		if not board.get_cell_tile_data(layers.background, mouse_tile):
			return
	for action in actions:
		if Input.is_action_pressed(action, true):
			if Input.is_action_just_pressed(action, true):
				_on_tile_action(tile_selected, action, ACTION_STATE.JUST_PRESSED, delta)
			else:
				_on_tile_action(tile_selected, action, ACTION_STATE.PRESSED, delta)
		if Input.is_action_just_released(action,true):
			_on_tile_action(tile_selected, action, ACTION_STATE.JUST_RELEASED, delta)


# Called when there is an input event.
func _input(event):
	if event is InputEventMouse:
		var mouse_tile = board.local_to_map(board.get_local_mouse_position())
		# If tile is within bounds.
		if board.get_cell_tile_data(layers.background, mouse_tile):
			update_tile_selected(mouse_tile)


## Adds and drops the preview pattern to the board, resets the cycle value, and
## updates the pattern preview.
## Returns true if successful.
func drop_pattern() -> bool:
	var pattern_id = preview.get_pattern_id()
	var status = board.add_pattern(layers.drop, pattern_id)
	if status == board.RETURN_STATUS.SUCCESS:
		drop.call([layers.drop, layers.background])
		cycle_value = 0
		update_preview()
		return true
	return false


## Returns a new pattern. 
func get_new_pattern() -> int:
	return randi_range(0, tile_set.get_patterns_count() - 1)


func set_cycle_period(value: float):
	cycle_period = value
	preview.progress_bar_set_max_value(value)


## Set the cycle value.
func set_cycle_value(value: float):
	var v = clampf(value, 0, cycle_period)
	cycle_value = v
	preview.progress_bar_set_value_inverse(v)


## Updates the array of actions.
func update_actions():
	var list = InputMap.get_actions()
	list = list.filter(func(s): return s.begins_with("game_"))
	actions = list


## Updates the preview pattern.
func update_preview():
	var new_pattern = get_new_pattern()
	preview.set_pattern_id(new_pattern)


func update_tile_selected(coordinates: Vector2i):
	tile_selected = coordinates
	board.clear_layer(layers.select)
	board.set_cell(layers.select, coordinates, \
			Constants.SOURCES.ANIM_TILE_SELECT, Constants.ANIMS.BASE.TILE_SELECT)


# Methods without implementation.


## Called when action on a tile is performed. 
func _on_tile_action(_tile: Vector2i, _action: StringName, _state: ACTION_STATE, _delta: float):
	pass
