## The main scene for the time mode of play.
extends CycleModeBase


## Adjust this value to match the width of the play area in the board.
@export var drop_width: int = 9
@onready var run_time: float = 0.0
@onready var score: int = 0
@onready var init_cycle_period: float = cycle_period
@onready var max_cycle_period: float = cycle_period * 2
@onready var level: int = 0: set = set_level
@onready var rows_cleared: int = 0: set = set_rows_cleared
var match_rows: Callable


# Called when the node enters the scene tree for the first time.
func _ready():
	board = $board
	tile_set = $board.tile_set
	layers = $board.layers
	atlas = $board.atlas
	preview = $preview_pattern
	commander = TileMapCommand.new(board)
	drop = commander.get_drop()
	effect = commander.get_path_map(atlas.TILES_SELF_MAPPING)
	match_rows = commander.get_match_rows("group")
	preview.init(tile_set, cycle_period)
	var pattern = get_new_pattern()
	preview.set_pattern_id(pattern)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	run_time += delta
	set_cycle_value(cycle_value + delta)
	if cycle_value >= cycle_period:
		if not drop_pattern():
			game_over()


func get_stats() -> Dictionary:
	var stats = {
		"Play Time": "%d:%02d" % [run_time / 60, int(run_time) % 60],
		"Level": level,
		"Score": score,
		"Rows Cleared": rows_cleared,
	}
	return stats


## Clears and scores matched rows in the drop layer.
## Returns the output of a Callable from [TileMapCommand.get_match_rows].
func score_board() -> Dictionary:
	var result = match_rows.call(layers.drop, drop_width)
	var matched_tiles = result[Vector2i(-1, -2)]
	var matched_rows = result[Vector2i(-1, -1)]
	if not matched_tiles.is_empty():
		board.clear_tiles(layers.drop, matched_tiles)
		drop.call([layers.drop, layers.background])
		score += matched_rows**2 * 100
		rows_cleared += matched_rows
	return result


func set_level(value: int):
	level = value
	# Update cycle_period.
	var new_cycle_period = init_cycle_period * (1.1 - 0.1 * exp(0.044 * level))
	cycle_period = clampf(new_cycle_period, 1, max_cycle_period)


func set_rows_cleared(value: int):
	rows_cleared = value
	update_level()


func update_level():
	var score_level = floori(score * 0.0004 - level * 0.4)
	var row_level = floori(rows_cleared * 0.1)
	var min_level = mini(score_level, row_level)
	if min_level > level:
		score += 1000
		set_level(min_level)


func _on_tile_mouse_event(tile: Vector2i, button: MouseButtonMask, pressed: bool):
	if button == MOUSE_BUTTON_MASK_LEFT:
		if pressed:
			# If tile is at the end of the path.
			if tile == board.path_get(-1):
				effect.call(layers.drop)
				score_board()
				board.clear_path()
			elif board.path_is_empty():
				if board.path_can_append(tile):
					board.path_append(tile)
			else:
				var path_end = board.path_get(-1)
				if tile.x == path_end.x or tile.y == path_end.y:
					# Extend path through shared column or row.
					var difference = tile - path_end
					var direction = sign(difference)
					for i in range(1, difference.length() + 1):
						var next_tile = path_end + i * direction
						if board.path_can_append(next_tile):
							board.path_append(next_tile)
						else:
							break
		elif not board.path_is_empty():
			if board.path_can_append(tile):
				board.path_append(tile)
			# If tile is second-to-last in the path.
			elif tile == board.path_get(-2):
				board.truncate_path(-2)
	elif button == MOUSE_BUTTON_MASK_RIGHT:
		if board.path_has(tile):
			if tile == board.path_get(-1):
				if pressed:
					board.clear_path()
			else:
				board.truncate_path(board.path_find(tile))
