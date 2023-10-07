extends Control


signal cross_button
signal play_button


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
		play_button.emit()


func _on_cross_button_pressed():
	cross_button.emit()


func _on_play_button_pressed():
	$AnimationPlayer.play("slide_out")
