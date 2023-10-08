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
		# Add a random pattern to the board.
		board.add_pattern(layers.drop, randi_range(0, tile_set.get_patterns_count()))
		drop.call(layers.drop)
		cycle_time = 0


func _on_pause_game_pressed():
	get_tree().paused = true
	# Instantiate ahd connects the pause menu.
	var pause_menu = preload("res://src/scene/pause_menu.tscn").instantiate()
	pause_menu.play_button.connect(_unpause_game)
	pause_menu.cross_button.connect(_quit_game)
	pause_menu.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	add_child(pause_menu)


func _quit_game():
	get_tree().quit()


func _unpause_game():
	remove_child($pause_menu)
	get_tree().paused = false
