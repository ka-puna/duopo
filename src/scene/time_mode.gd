extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


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
