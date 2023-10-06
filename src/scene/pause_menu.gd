extends Control


signal quit_game
signal unpause_game


var data = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	update_data_label()
	$AnimationPlayer.play("slide_in")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


## Set the data to display.
func set_data(new_data: Dictionary) -> void:
	data = new_data


## Update data_label text to reflect data.
func update_data_label() -> void:
	if data.is_empty():
		$Group/data_label.text = ""
		return
	for key in data.keys():
		var string = "[b]" + key + ":[/b] " + str(data[key]) + "\n"
		$Group/data_label.append_text(string)


func _on_quit_game_pressed():
	quit_game.emit()


func _on_resume_game_pressed():
	$AnimationPlayer.play("slide_out")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "slide_out":
		unpause_game.emit()
