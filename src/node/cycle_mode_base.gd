## The base script for a game mode scene where patterns are dropped based on a cycling value.
class_name CycleModeBase
extends Control


var PauseMenu = preload("res://src/scene/pause_menu.tscn")


## The position of the selected tile. Set its intial position in the editor.
@export var tile_selected: Vector2i
## The period between drops in units such as seconds.
@export var cycle_period: float = 10.0: set = set_cycle_period
@onready var cycle_value: float = 0.0: set = set_cycle_value
var atlas: TileAtlas
var board: TileMapCustom
var drop: Callable
var layers: Dictionary
var tile_set: TileSet
var preview: PreviewPattern


# Called when there is an input event.
func _input(event):
	if event is InputEventMouse:
		var clicked_tile = board.local_to_map(board.get_local_mouse_position())
		# If tile is within bounds.
		if board.get_cell_tile_data(layers.background, clicked_tile):
			var button_mask = event.get_button_mask()
			var pressed = event is InputEventMouseButton and event.pressed
			update_tile_selected(clicked_tile)
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
	return randi_range(0, tile_set.get_patterns_count() - 1)


## Returns a dictionary with human-readable keys and values.
func get_stats() -> Dictionary:
	return {}


## Restarts the game mode.
func restart_game():
	get_tree().reload_current_scene()
	get_tree().paused = false


func set_cycle_period(value: float):
	cycle_period = value
	preview.progress_bar_set_max_value(value)


## Set the cycle value.
func set_cycle_value(value: float):
	var v = clampf(value, 0, cycle_period)
	cycle_value = v
	preview.progress_bar_set_value_inverse(v)


## Updates the preview pattern.
func update_preview():
	var new_pattern = get_new_pattern()
	preview.set_pattern_id(new_pattern)


func update_tile_selected(coordinates: Vector2i):
	tile_selected = coordinates
	board.clear_layer(layers.select)
	board.set_cell(layers.select, coordinates, \
			atlas.SOURCES.ANIM_TILE_SELECT, atlas.ANIMS.BASE.TILE_SELECT)


func _on_drop_pattern_pressed():
	drop_pattern()


func _on_pause_game_pressed():
	get_tree().paused = true
	var pause_menu = _open_pause_menu(_unpause_game, _quit_game)
	add_child(pause_menu)
	pause_menu.set_display_data(get_stats())


## Opens the pause menu and connects its signals to the given Callables.
## Returns the pause menu node.
func _open_pause_menu(play_button_callback: Callable, cross_button_callback: Callable) -> Node:
	var pause_menu = PauseMenu.instantiate()
	pause_menu.play_button.connect(play_button_callback)
	pause_menu.cross_button.connect(cross_button_callback)
	pause_menu.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	pause_menu.set_name("pause_menu")
	return pause_menu


func _quit_game():
	get_tree().quit()


func _unpause_game():
	$pause_menu.queue_free()
	get_tree().paused = false


# Methods without implementation.


## Called when a tile is pressed by a click or drag mouse event.
func _on_tile_mouse_event(_tile: Vector2i, _button: MouseButtonMask, _pressed: bool):
	pass

