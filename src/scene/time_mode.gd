## The main scene for the time mode of play.
extends Control


var PauseMenu = preload("res://src/scene/pause_menu.tscn")
var ParticleEffect = preload("res://src/scene/particle_effect.tscn")

enum DIRECTION {LEFT = 0, RIGHT = 1, UP = 2, DOWN = 3}
const move_selection_vector: Array[Vector2i] = [
	Vector2i(-1, 0),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(0, 1)
]

## Adjust this value to match the width of the play area in the board.
@export var drop_width: int = 9
## The approximate minimum time in seconds between tile_selected movements.
@export var move_selection_period: float = 0.125
@onready var move_selection_value: Array[float] = [0.0, 0.0, 0.0, 0.0]
## The position of the selected tile. Set its intial position in the editor.
@export var tile_selected: Vector2i
## The intial period between drops, in seconds.
@export var init_cycle_period: float = 10.0
## The minimum period between drops, in seconds.
@export var min_cycle_period: float = 1.0
@onready var run_time: float = 0.0
var level: int: set = set_level
@onready var level_label = $Level
@onready var path = Path.new()
@onready var rows_cleared: int = 0: set = set_rows_cleared
var score: int: set = set_score
@onready var score_label = $Score
var layers: Dictionary
var pattern_level: int: set = set_pattern_level
# A non-rectangular array of integers storing pattern indices.
var patterns: Array
var tile_set: TileSet
var effect: Callable
var match_rows: Callable

var board: TileMapCustom
var cycle: CycleValue
var commander: TileMapCommand
var game_input: GameInput
var preview: PreviewPattern
var sfx_player: SoundEffectPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	board = $board
	cycle = CycleValue.new(0.0, 0.0, init_cycle_period)
	preview = $preview_pattern
	sfx_player = $sound_effect_player
	commander = TileMapCommand.new(board)
	level = 0
	score = 0
	pattern_level = 0
	layers = board.layers
	tile_set = board.tile_set
	game_input = GameInput.new(board, layers.background)
	game_input.tile_action.connect(_on_tile_action)
	game_input.tile_selection.connect(update_tile_selected)
	update_tile_selected(tile_selected)
	board.update_terrains()
	cycle.cycle_value_changed.connect(_on_cycle_value_changed)
	cycle.cycle_value_overflowed.connect(_on_cycle_value_overflowed)
	preview.init(tile_set, init_cycle_period)
	var pattern = get_new_pattern()
	preview.set_pattern_id(pattern)
	effect = commander.get_self_map(Constants.TILES_SELF_MAPPING)
	match_rows = commander.get_match_rows("group")
	path.updated.connect(_on_path_updated)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	game_input.process(delta)
	run_time += delta
	cycle.value += delta


# Called when there is an input event.
func _input(event):
	game_input.input(event)


## Returns true if the tile can be added to the path.
func can_append_to_path(tile: Vector2i) -> bool:
	for layer in layers.values():
		var tile_data = board.get_cell_tile_data(layer, tile)
		if tile_data and not tile_data.get_custom_data("pathable"):
			return false
	return path.can_append(tile)


## Moves tiles in 'drop_layers'[0] to the lowest row without obstruction by solid tiles.
##		'drop_layers': An array of layers to check for solid tiles.
func drop(drop_layers: Array):
	var tiles = board.get_used_cells(drop_layers[0])
	var has_dropped = false
	# Sort tiles from bottom-to-top, then left-to-right.
	tiles.sort_custom(func(a, b): return a.y > b.y or a.y == b.y and a.x < b.x)
	for i in tiles.size():
		var tile_below = tiles[i] + Vector2i(0, 1)
		var is_blocked = false
		for layer in drop_layers:
			if board.tile_get_data(layer, tile_below, "solid"):
				is_blocked = true
				break
		while not is_blocked:
			# Move the tile down.
			var tile_type = board.get_cell_atlas_coords(drop_layers[0], tiles[i], false)
			board.erase_cell(drop_layers[0], tiles[i])
			tiles[i] = tile_below
			board.set_cell(drop_layers[0], tiles[i], Constants.SOURCES.TILES, tile_type)
			has_dropped = true
			# Update while-loop condition.
			tile_below = tile_below + Vector2i(0, 1)
			for layer in drop_layers:
				if board.tile_get_data(layer, tile_below, "solid"):
					is_blocked = true
					break
	if has_dropped:
		_on_tiles_dropped()


## Adds and drops the preview pattern to the board, resets the cycle value, and
## updates the pattern preview.
## Returns true if successful.
##		'drop_layers': An array of layers to use when dropping tiles.
func drop_pattern(drop_layers: Array) -> bool:
	var pattern_id = preview.get_pattern_id()
	var status = board.add_pattern(layers.drop, pattern_id)
	if status == board.RETURN_STATUS.SUCCESS:
		drop(drop_layers)
		cycle.value = 0.0
		update_preview()
		return true
	return false


## Opens the pause menu, with options to restart or quit the game.
func game_over():
	get_tree().paused = true
	var pause_menu = open_pause_menu(restart_game, restart_game, quit_game)
	add_child(pause_menu)
	pause_menu.set_display_data(get_stats())


func get_new_pattern(repeat = true) -> int:
	var limit = patterns.size()
	var random_f = randf_range(0, limit)
	while random_f == limit:
		random_f = randf_range(0, limit)
	var index = floori(random_f)
	var frac = random_f - index
	if frac < patterns[index][0] or not repeat:
		var random_i = randi_range(1, patterns[index].size() - 1)
		return patterns[index][random_i]
	else:
		return get_new_pattern(false)


func get_stats() -> Dictionary:
	var stats = {
		"Play Time": "%d:%02d" % [run_time / 60, int(run_time) % 60],
		"Level": level,
		"Score": score,
		"Rows Cleared": rows_cleared,
	}
	return stats


## Opens the pause menu and connects its signals to the given Callables.
## Returns the pause menu node.
func open_pause_menu(play_button_callback: Callable, open_circle_button_callback: Callable, cross_button_callback: Callable) -> Node:
	var pause_menu = PauseMenu.instantiate()
	pause_menu.play_button.connect(play_button_callback)
	pause_menu.open_circle_button.connect(open_circle_button_callback)
	pause_menu.cross_button.connect(cross_button_callback)
	pause_menu.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	pause_menu.set_name("pause_menu")
	return pause_menu


func pause_game():
	get_tree().paused = true
	var pause_menu = open_pause_menu(unpause_game, restart_game, quit_game)
	add_child(pause_menu)
	pause_menu.set_display_data(get_stats())


func quit_game():
	get_tree().quit()


## Restarts the game mode.
func restart_game():
	get_tree().reload_current_scene()
	get_tree().paused = false


## Clears and scores matched rows in the drop layer.
## Returns the output of a Callable from [TileMapCommand.get_match_rows].
func score_board() -> Dictionary:
	var result = match_rows.call(layers.drop, drop_width)
	var matched_tiles = result[Vector2i(-1, -2)]
	var matched_rows = result[Vector2i(-1, -1)]
	if not matched_tiles.is_empty():
		board.clear_tiles(layers.drop, matched_tiles)
		# Add particle effects.
		for tile in matched_tiles:
			var pos: Vector2 = board.map_to_local(tile)
			var particle_effect = ParticleEffect.instantiate()
			particle_effect.position = board.to_global(pos)
			add_child(particle_effect)
			particle_effect.expired.connect(_on_expired)
		drop([layers.drop, layers.background])
		score += matched_rows**2 * 100
		rows_cleared += matched_rows
	return result


func set_level(value: int):
	level = value
	level_label.text = "Level\n%d" % level
	# Update cycle periods.
	var cycle_period = init_cycle_period * (1.1 - 0.1 * exp(0.044 * level))
	cycle_period = max(cycle_period, min_cycle_period)
	cycle.max_value = cycle_period
	preview.progress_bar_set_max_value(cycle_period)


## Set the patterns used by the game according to 'pattern_level'. 
func set_pattern_level(value: int):
	pattern_level = value
	match value:
		0:
			# 3-height patterns.
			patterns = Constants.SAMPLE.slice(0, 6, 1, true)
		1:
			# 3-height and 1-height patterns.
			patterns = Constants.SAMPLE.slice(0, 6, 1, true)
			patterns.append_array(Constants.SAMPLE.slice(10, 14, 1, true))
		2:
			# 3-height and 2-height patterns
			patterns = Constants.SAMPLE.slice(0, 6, 1, true)
			patterns.append_array(Constants.SAMPLE.slice(6, 10, 1, true))
		3:
			# 3-height and 4-height patterns.
			patterns = Constants.SAMPLE.slice(0, 6, 1, true)
			patterns.append_array(Constants.SAMPLE.slice(14, 19, 1, true))
		4:
			# 4-height and 2-height patterns.
			patterns = Constants.SAMPLE.slice(14, 19, 1, true)
			patterns.append_array(Constants.SAMPLE.slice(6, 10, 1, true))
		5:
			# 2-height, 1-height, and 4-height patterns.
			patterns = Constants.SAMPLE.slice(6, 14, 1, true)
			patterns.append_array(Constants.SAMPLE.slice(14, 19, 1, true))
		6:
			# 3-height patterns.
			patterns = Constants.SAMPLE.slice(0, 14, 1, true)
		7:
			# 3-height and 2-height patterns.
			patterns = Constants.SAMPLE.slice(0, 6, 1, true)
			patterns.append_array(Constants.SAMPLE.slice(6, 10, 1, true))
		8:
			# 3-height, 2-height, and 1-height patterns.
			patterns = Constants.SAMPLE.slice(0, 14, 1, true)
		9:
			# Full pattern set.
			patterns = Constants.SAMPLE.duplicate(true)
		_:
			set_pattern_level(value % 10)
			return
	# Correct subset values.
	var num_patterns = patterns.size()
	for subset in patterns:
		if subset[0] < 1:
			var p = subset[0]
			subset[0] = (p * num_patterns + p - 1)/(num_patterns + p -1)


func set_rows_cleared(value: int):
	rows_cleared = value
	update_levels()


func set_score(value: int):
	score = value
	score_label.text = str(value)


func unpause_game():
	$pause_menu.queue_free()
	get_tree().paused = false


## Updates the preview pattern.
func update_preview():
	var new_pattern = get_new_pattern()
	preview.set_pattern_id(new_pattern)


func update_levels():
	var score_level = floori(score * 0.0004 - level * 0.4)
	var row_level = floori(rows_cleared * 0.1)
	var min_level = mini(score_level, row_level)
	if min_level > level:
		score += 1000
		set_level(min_level)
	var min_pattern_level = floori(min_level * 0.2)
	if min_pattern_level > pattern_level:
		set_pattern_level(min_pattern_level)


func update_tile_selected(coordinates: Vector2i):
	tile_selected = coordinates
	board.clear_layer(layers.select)
	board.set_cell(layers.select, coordinates, \
			Constants.SOURCES.ANIM_TILE_SELECT, Constants.ANIMS.BASE.TILE_SELECT)


# Handles game_* directional actions.
func _game_directional_action(direction: DIRECTION, state: GameInput.ACTION_STATE, delta: float):
	if state == game_input.ACTION_STATE.JUST_RELEASED:
		move_selection_value[direction] = 0.0
	else:
		if state == game_input.ACTION_STATE.PRESSED:
			move_selection_value[direction] += delta
			if move_selection_value[direction] >= move_selection_period:
				var vector = move_selection_vector[direction]
				var next_tile = tile_selected + vector
				# If next_tile is within bounds.
				if board.get_cell_tile_data(layers.background, next_tile):
					update_tile_selected(next_tile)
				move_selection_value[direction] = 0.001
		elif state == game_input.ACTION_STATE.JUST_PRESSED:
			var vector = move_selection_vector[direction]
			var next_tile = tile_selected + vector
			# If next_tile is within bounds.
			if board.get_cell_tile_data(layers.background, next_tile):
				move_selection_value[direction] = 0.001
				update_tile_selected(next_tile)


func _on_drop_pattern_pressed():
	drop_pattern([layers.drop, layers.background])


func _on_expired(node: Node):
	node.queue_free()	


func _on_path_updated():
	# Update the drawing of the path layer.
	board.clear_layer(layers.path)
	if not path.is_empty():
		board.set_cells_terrain_path(layers.path, path.get_tiles(), \
				board.terrains.path.set, board.terrains.path.index)
		# Set the last tile to an animated tile.
		board.set_cell(layers.path, path.get_index(-1), \
				Constants.SOURCES.ANIM_PATH_END, Constants.ANIMS.BASE.PATH_END)
	sfx_player.play(sfx_player.SOUNDS.PATH_UPDATED)


func _on_pause_game_pressed():
	pause_game()


func _on_tile_action(action: StringName, state: GameInput.ACTION_STATE, delta: float):
	match action:
		"game_clear_path":
			if state == game_input.ACTION_STATE.JUST_PRESSED:
				path.clear()
		"game_drop_pattern":
			if state == game_input.ACTION_STATE.JUST_PRESSED:
				drop_pattern([layers.drop, layers.background])
		"game_select_tile_primary":
			if path.is_empty():
				if state == game_input.ACTION_STATE.JUST_PRESSED:
					if can_append_to_path(tile_selected):
						path.append(tile_selected)
			# If tile is at the end of the path.
			elif tile_selected == path.get_index(-1):
				if state == game_input.ACTION_STATE.JUST_PRESSED:	
					effect.call(layers.drop, path.get_tiles())
					score_board()
					path.clear()
			elif state != game_input.ACTION_STATE.JUST_RELEASED:
				# If tile is second-to-last in the path.
				if tile_selected == path.get_index(-2):
					path.truncate(-2)
				else:
					var path_end = path.get_index(-1)
					if tile_selected.x == path_end.x or tile_selected.y == path_end.y:
						# Extend path through shared column or row.
						var difference = tile_selected - path_end
						var direction = sign(difference)
						for i in range(1, difference.length() + 1):
							var next_tile = path_end + i * direction
							if can_append_to_path(next_tile):
								path.append(next_tile)
							else:
								break
		"game_select_tile_secondary":
			if path.has(tile_selected):
				if tile_selected == path.get_index(-1):
					if state == game_input.ACTION_STATE.JUST_PRESSED:
						path.clear()
				elif state != game_input.ACTION_STATE.JUST_RELEASED:
					path.truncate(path.find(tile_selected))
		"game_left":
			_game_directional_action(DIRECTION.LEFT, state, delta)
		"game_right":
			_game_directional_action(DIRECTION.RIGHT, state, delta)
		"game_up":
			_game_directional_action(DIRECTION.UP, state, delta)
		"game_down":
			_game_directional_action(DIRECTION.DOWN, state, delta)


func _on_tiles_dropped():
	sfx_player.play(sfx_player.SOUNDS.TILES_DROPPED)


func _on_cycle_value_changed(value):
	preview.progress_bar_set_value_inverse(value)


func _on_cycle_value_overflowed():
	if not drop_pattern([layers.drop, layers.background]):
		game_over()
