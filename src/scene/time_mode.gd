extends Control


## The period between drops in seconds.
@export var cycle_period = 30
var board: TileMapPathable
var tile_set: TileSet
var layers: Dictionary
var atlas
var commander
var drop: Callable
var cycle_time


# Called when the node enters the scene tree for the first time.
func _ready():
	board = $board
	tile_set = $board.tile_set
	layers = $board.layers
	atlas = $board.atlas
	commander = preload("res://src/node/tile_map/tile_map_command.gd").new(board)
	drop = commander.get_func_drop_layer()
	cycle_time = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cycle_time = cycle_time + delta
	if cycle_time >= cycle_period:
		# Add a random pattern to the board. If unable to, end the game.
		var pattern = randi_range(0, tile_set.get_patterns_count())
		if board.add_pattern(layers.drop, pattern) != board.RETURN_STATUS.SUCCESS:
			game_over()
		drop.call(layers.drop)
		cycle_time = 0


## Opens the pause menu, with options to restart or quit the game.
func game_over():
	get_tree().paused = true
	var pause_menu = _open_pause_menu(restart_game, _quit_game)
	add_child(pause_menu)


## Restarts the time mode game.
func restart_game():
	get_tree().reload_current_scene()
	get_tree().paused = false


## Opens the pause menu and connects its signals to the given Callables.
## Returns the pause menu node.
func _open_pause_menu(play_button_callback: Callable, cross_button_callback: Callable) -> Node:
	var pause_menu = preload("res://src/scene/pause_menu.tscn").instantiate()
	pause_menu.play_button.connect(play_button_callback)
	pause_menu.cross_button.connect(cross_button_callback)
	pause_menu.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	return pause_menu


func _on_pause_game_pressed():
	get_tree().paused = true
	var pause_menu = _open_pause_menu(_unpause_game, _quit_game)
	add_child(pause_menu)


func _quit_game():
	get_tree().quit()


func _unpause_game():
	remove_child($pause_menu)
	get_tree().paused = false
