extends Control


signal quit_game


var data = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	update_data_label()


## Set the data to display.
func set_data(new_data: Dictionary) -> void:
	data = new_data


## Update data_label text to reflect data.
func update_data_label() -> void:
	if data.is_empty():
		$data_label.text = ""
		return
	for key in data.keys():
		var string = "[b]" + key + ":[/b] " + str(data[key]) + "\n"
		$data_label.append_text(string)
