extends Control


signal cross_button
signal play_button


@onready var display_data = $Group/display_data
var use_enter_anim = true
var use_exit_anim = true


# Called when the node enters the scene tree for the first time.
func _ready():
	grab_focus()
	if use_enter_anim:
		$AnimationPlayer.play("enter")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


## Set the data to display.
func set_display_data(data: Dictionary) -> void:
	display_data.update_text(data)


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "exit":
		play_button.emit()


func _on_cross_button_pressed():
	cross_button.emit()


func _on_play_button_pressed():
	if use_exit_anim:
		$AnimationPlayer.play("exit")
	else:
		play_button.emit()
