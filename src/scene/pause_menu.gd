extends Control


signal quit_game
signal unpause_game


var display_data


# Called when the node enters the scene tree for the first time.
func _ready():
	display_data = $Group/display_data
	$AnimationPlayer.play("slide_in")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


## Set the data to display.
func set_display_data(new_data: Dictionary) -> void:
	display_data.data = new_data


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "slide_out":
		unpause_game.emit()

func _on_quit_game_pressed():
	quit_game.emit()


func _on_resume_game_pressed():
	$AnimationPlayer.play("slide_out")
