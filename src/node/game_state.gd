## GameState manages variables such as score and level.
class_name GameState
extends Node

signal level_updated(value: int)
signal pattern_level_updated(value: int)
signal score_updated(value: int)


var level: int: set = set_level
var pattern_level: int: set = set_pattern_level
var rows_cleared: int: set = set_rows_cleared
var run_time: float
var score: int: set = set_score


# Called when the node enters the scene tree for the first time.
func _ready():
	level = 0
	pattern_level = 0
	rows_cleared = 0
	run_time = 0.0
	score = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	run_time += delta


# Returns a human-readable dictionary of the current game statistics.
func get_stats() -> Dictionary:
	var stats = {
		"Play Time": "%d:%02d" % [run_time / 60, int(run_time) % 60],
		"Level": level,
		"Score": score,
		"Rows Cleared": rows_cleared,
	}
	return stats


func set_score(value: int):
	score = value
	score_updated.emit(score)


func set_level(value: int):
	level = value
	level_updated.emit(level)


func set_pattern_level(value: int):
	pattern_level = value
	pattern_level_updated.emit(pattern_level)


func set_rows_cleared(value: int):
	rows_cleared = value
	update_levels()


func update_levels():
	var score_level = floori(score * 0.0004 - level * 0.4)
	var row_level = floori(rows_cleared * 0.1)
	var min_level = mini(score_level, row_level)
	if min_level > level:
		score += 1000
		level = min_level
	var min_pattern_level = floori(min_level * 0.2)
	if min_pattern_level > pattern_level:
		pattern_level = min_pattern_level
