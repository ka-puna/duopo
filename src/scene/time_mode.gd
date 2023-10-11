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
