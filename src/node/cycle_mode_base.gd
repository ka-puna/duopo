## The base script for a game mode scene where patterns are dropped based on a cycling value.
class_name CycleModeBase
extends Control


var PauseMenu = preload("res://src/scene/pause_menu.tscn")


## The period between drops in units such as seconds.
@export var cycle_period = 30: set = set_cycle_period
var board: TileMapCustom
var tile_set: TileSet
var layers: Dictionary
var atlas: TileAtlas
var preview: PreviewPattern
var commander: TileMapCommand
var drop: Callable
var effect: Callable
@onready var cycle_value = 0: set = set_cycle_value


# Called when there is an input event.
func _input(event):
	if event is InputEventMouse:
		var clicked_tile = board.local_to_map(board.get_local_mouse_position())
		# If tile is within bounds.
		if board.get_cell_tile_data(board.layers.background, clicked_tile):
			var button_mask = event.get_button_mask()
			var pressed = event is InputEventMouseButton and event.pressed
			_on_tile_mouse_event(clicked_tile, button_mask, pressed)


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


## Opens the pause menu, with options to restart or quit the game.
func game_over():
	get_tree().paused = true
	var pause_menu = _open_pause_menu(restart_game, _quit_game)
	add_child(pause_menu)
	pause_menu.set_display_data(get_stats())


## Returns a new pattern. 
func get_new_pattern() -> int:
	return randi_range(0, tile_set.get_patterns_count())


## Returns a dictionary with human-readable keys and values.
func get_stats() -> Dictionary:
	return {}


## Updates the preview pattern.
func update_preview():
	var new_pattern = get_new_pattern()
	preview.set_pattern_id(new_pattern)


## Restarts the game mode.
func restart_game():
	get_tree().reload_current_scene()
	get_tree().paused = false


func set_cycle_period(value: float):
	cycle_period = value
	preview.progress_bar_set_max_value(value)


## Set the cycle value.
func set_cycle_value(value: float):
	var v = clamp(value, 0, cycle_period)
	cycle_value = v
	preview.progress_bar_set_value_inverse(v)


func _on_drop_pattern_pressed():
	drop_pattern()


## Opens the pause menu and connects its signals to the given Callables.
## Returns the pause menu node.
func _open_pause_menu(play_button_callback: Callable, cross_button_callback: Callable) -> Node:
	var pause_menu = PauseMenu.instantiate()
	pause_menu.play_button.connect(play_button_callback)
	pause_menu.cross_button.connect(cross_button_callback)
	pause_menu.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	return pause_menu


func _on_pause_game_pressed():
	get_tree().paused = true
	var pause_menu = _open_pause_menu(_unpause_game, _quit_game)
	add_child(pause_menu)
	pause_menu.set_display_data(get_stats())


## Called when a tile is pressed by a click or drag mouse event.
func _on_tile_mouse_event(_tile: Vector2i, _button: MouseButtonMask, _pressed: bool):
	pass


func _quit_game():
	get_tree().quit()


func _unpause_game():
	remove_child($pause_menu)
	get_tree().paused = false
