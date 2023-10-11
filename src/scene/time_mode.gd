## The main scene for the time mode of play.
extends Control


var PauseMenu = preload("res://src/scene/pause_menu.tscn")
var TileMapCommand = preload("res://src/node/tile_map/tile_map_command.gd")


## The period between drops in units such as seconds.
@export var cycle_period = 30: set = set_cycle_period
@onready var board: TileMapPathable = $board
@onready var tile_set: TileSet = $board.tile_set
@onready var layers: Dictionary = $board.layers
@onready var atlas: TileAtlas = $board.atlas
@onready var preview: PreviewPattern = $preview_pattern
@onready var commander = TileMapCommand.new(board)
@onready var drop: Callable = commander.get_drop()
@onready var path_effect: Callable = commander.get_path_map(atlas.TILES_SELF_MAPPING)
@onready var cycle_value = 0: set = set_cycle_value


# Called when the node enters the scene tree for the first time.
func _ready():
	preview.init(tile_set, cycle_period)
	var pattern = get_new_pattern()
	preview.set_pattern_id(pattern)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	set_cycle_value(cycle_value + delta)
	if cycle_value >= cycle_period:
		var pattern = get_next_pattern()
		if drop_pattern(pattern) != board.RETURN_STATUS.SUCCESS:
			game_over()


# Called when there is an input event.
func _input(event):
	if event is InputEventMouse:
		var clicked_tile = board.local_to_map(board.get_local_mouse_position())
		# If tile is within bounds.
		if board.get_cell_tile_data(board.layers.background, clicked_tile):
			var button_mask = event.get_button_mask()
			match button_mask:
				MOUSE_BUTTON_MASK_RIGHT:
					# If clicked tile is at the end of the path.
					if clicked_tile == board.path_get(-1):
						if event is InputEventMouseButton and event.pressed:
							board.clear_path()
					elif board.path_has(clicked_tile):
						board.truncate_path(board.path_find(clicked_tile))
				MOUSE_BUTTON_MASK_LEFT:
					if board.path_can_append(clicked_tile) and \
							not board.path_is_empty():
						board.path_append(clicked_tile)
					elif event is InputEventMouseButton and event.pressed:
						# If clicked tile is at the end of the path.
						if clicked_tile == board.path_get(-1):
							path_effect.call(layers.drop)
							_score_board()
							board.clear_path()
						elif board.path_is_empty():
							if board.path_can_append(clicked_tile):
								board.path_append(clicked_tile)
						else:
							var path_end = board.path_get(-1)
							if clicked_tile.x == path_end.x or clicked_tile.y == path_end.y:
								# Extend path through shared column or row.
								var difference = clicked_tile - path_end
								var direction = sign(difference)
								for i in range(1, difference.length() + 1):
									var tile = path_end + i * direction
									if board.path_can_append(tile):
										board.path_append(tile)
									else:
										break


## Adds the pattern associated with 'id' to the board.
## Returns a [enum TileMapCustom.RETURN_STATUS] value.
func drop_pattern(id: int) -> int:
	var status = board.add_pattern(layers.drop, id)
	if status == board.RETURN_STATUS.SUCCESS:
		drop.call([layers.drop, layers.background])
		cycle_value = 0
	return status


## Opens the pause menu, with options to restart or quit the game.
func game_over():
	get_tree().paused = true
	var pause_menu = _open_pause_menu(restart_game, _quit_game)
	add_child(pause_menu)


## Returns a new pattern. 
func get_new_pattern() -> int:
	return randi_range(0, tile_set.get_patterns_count())


## Returns the index of next pattern to add to the drop layer.
func get_next_pattern() -> int:
	var next_pattern = preview.get_pattern_id()
	var new_pattern = get_new_pattern()
	preview.set_pattern_id(new_pattern)
	return next_pattern


## Restarts the time mode game.
func restart_game():
	get_tree().reload_current_scene()
	get_tree().paused = false


func set_cycle_period(value: float):
	cycle_period = value
	preview.progress_bar_set_max_value(value)


## Set the cycle time.
func set_cycle_value(value: float):
	var v = clamp(value, 0, cycle_period)
	cycle_value = v
	preview.progress_bar_set_value_inverse(v)


func _on_drop_pattern_pressed():
	var pattern = get_next_pattern()
	drop_pattern(pattern)


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


func _quit_game():
	get_tree().quit()


func _score_board():
	var result = board.match_rows(layers.drop)
	var matched_tiles = result[Vector2i(-1, -2)]
	if not matched_tiles.is_empty():
		board.clear_tiles(layers.drop, matched_tiles)
		drop.call([layers.drop, layers.background])


func _unpause_game():
	remove_child($pause_menu)
	get_tree().paused = false
