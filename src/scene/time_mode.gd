## The main scene for the time mode of play.
extends CycleModeBase


var PauseMenu = preload("res://src/scene/pause_menu.tscn")
var ParticleEffect = preload("res://src/scene/particle_effect.tscn")

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
@onready var init_cycle_period: float = cycle_period
@onready var max_cycle_period: float = cycle_period * 2
@onready var run_time: float = 0.0
var level: int: set = set_level
@onready var level_label = $Level
@onready var path = Path.new()
@onready var rows_cleared: int = 0: set = set_rows_cleared
var score: int: set = set_score
@onready var score_label = $Score
var pattern_level: int: set = set_pattern_level
# A non-rectangular array of integers storing pattern indices.
var patterns: Array
var sfx_player: SoundEffectPlayer
var commander: TileMapCommand
var effect: Callable
var match_rows: Callable


# Called when the node enters the scene tree for the first time.
func _ready():
	board = $board
	preview = $preview_pattern
	sfx_player = $sound_effect_player
	commander = TileMapCommand.new(board)
	effect = commander.get_self_map(Constants.TILES_SELF_MAPPING)
	match_rows = commander.get_match_rows("group")
	path.updated.connect(_on_path_updated)
	level = 0
	score = 0
	pattern_level = 0
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super(delta)
	run_time += delta
	set_cycle_value(cycle_value + delta)
	if cycle_value >= cycle_period:
		if not drop_pattern([layers.drop, layers.background]):
			game_over()


## Returns true if the tile can be added to the path.
func can_append_to_path(tile: Vector2i) -> bool:
	for layer in layers.values():
		var tile_data = board.get_cell_tile_data(layer, tile)
		if tile_data and not tile_data.get_custom_data("pathable"):
			return false
	return path.can_append(tile)


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
	# Update cycle_period.
	var new_cycle_period = init_cycle_period * (1.1 - 0.1 * exp(0.044 * level))
	cycle_period = clampf(new_cycle_period, 1, max_cycle_period)


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


# Handles game_* directional actions.
func _game_directional_action(direction: DIRECTION, state: ACTION_STATE, delta: float):
	if state == ACTION_STATE.JUST_RELEASED:
		move_selection_value[direction] = 0.0
	else:
		if state == ACTION_STATE.PRESSED:
			move_selection_value[direction] += delta
			if move_selection_value[direction] >= move_selection_period:
				var vector = move_selection_vector[direction]
				var next_tile = tile_selected + vector
				# If next_tile is within bounds.
				if board.get_cell_tile_data(layers.background, next_tile):
					update_tile_selected(next_tile)
				move_selection_value[direction] = 0.001
		elif state == ACTION_STATE.JUST_PRESSED:
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


func _on_tile_action(tile: Vector2i, action: StringName, state: ACTION_STATE, delta: float):
	match action:
		"game_clear_path":
			if state == ACTION_STATE.JUST_PRESSED:
				path.clear()
		"game_drop_pattern":
			if state == ACTION_STATE.JUST_PRESSED:
				drop_pattern([layers.drop, layers.background])
		"game_select_tile_primary":
			if path.is_empty():
				if state == ACTION_STATE.JUST_PRESSED:
					if can_append_to_path(tile):
						path.append(tile)
			# If tile is at the end of the path.
			elif tile == path.get_index(-1):
				if state == ACTION_STATE.JUST_PRESSED:	
					effect.call(layers.drop, path.get_tiles())
					score_board()
					path.clear()
			elif state != ACTION_STATE.JUST_RELEASED:
				# If tile is second-to-last in the path.
				if tile == path.get_index(-2):
					path.truncate(-2)
				else:
					var path_end = path.get_index(-1)
					if tile.x == path_end.x or tile.y == path_end.y:
						# Extend path through shared column or row.
						var difference = tile - path_end
						var direction = sign(difference)
						for i in range(1, difference.length() + 1):
							var next_tile = path_end + i * direction
							if can_append_to_path(next_tile):
								path.append(next_tile)
							else:
								break
		"game_select_tile_secondary":
			if path.has(tile):
				if tile == path.get_index(-1):
					if state == ACTION_STATE.JUST_PRESSED:
						path.clear()
				elif state != ACTION_STATE.JUST_RELEASED:
					path.truncate(path.find(tile))
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
