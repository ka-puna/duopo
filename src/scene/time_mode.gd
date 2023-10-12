## The main scene for the time mode of play.
extends CycleModeBase


@onready var run_time = 0
@onready var score = 0
@onready var lines_cleared = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	board = $board
	tile_set = $board.tile_set
	layers = $board.layers
	atlas = $board.atlas
	preview = $preview_pattern
	commander = TileMapCommand.new(board)
	drop = commander.get_drop()
	path_effect = commander.get_path_map(atlas.TILES_SELF_MAPPING)
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
		"Score": score,
		"Lines Cleared": lines_cleared,
	}
	return stats


func score_board() -> Dictionary:
	var result = super()
	var matched_rows = result[Vector2i(-1, -1)]
	score += matched_rows**2 * 100
	lines_cleared += matched_rows
	return result


func _on_tile_mouse_event(tile: Vector2i, button: MouseButtonMask, pressed: bool):
	if button == MOUSE_BUTTON_MASK_LEFT:
		if pressed:
			# If tile is at the end of the path.
			if tile == board.path_get(-1):
				path_effect.call(layers.drop)
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
