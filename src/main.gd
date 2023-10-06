## Main is entry point of the game.
extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_quit_game_pressed():
	get_tree().quit()


func _on_time_mode_pressed():
	get_tree().change_scene_to_file("res://src/scene/time_mode.tscn")
