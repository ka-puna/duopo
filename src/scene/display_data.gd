## The display_data scene displays a dictionary as line-separated strings.
extends Control


signal quit_game


var data = {}: set = set_data


# Called when the node enters the scene tree for the first time.
func _ready():
	update_data_label()


## Set the data to display.
func set_data(new_data: Dictionary) -> void:
	data = new_data
	update_data_label()


## Update data_label text to reflect data.
func update_data_label() -> void:
	if data.is_empty():
		$data_label.text = ""
		return
	for key in data.keys():
		var string = "[b]%-24s[/b] %s" % [key + ":", data[key]] + "\n"
		$data_label.append_text(string)
