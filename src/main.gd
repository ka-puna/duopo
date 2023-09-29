## Main is entry point of the game.
extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_quit_game_pressed():
	get_tree().quit()
