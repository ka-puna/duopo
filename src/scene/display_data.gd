## The display_data scene displays a dictionary as line-separated strings.
extends Control


const TERRAINS = {
	"BACKGROUND": {
		"SET": 0,
		"INDEX": 0,
	},
}
@onready var data_label = $data_label
@onready var text_bg = $TextBG
@onready var tile_size = $TextBG.tile_set.tile_size


# Called when the node enters the scene tree for the first time.
func _ready():
	_update_background()


## Set the size of the display to the dimension of 'rectangle'.
func set_display_size(rectangle: Vector2):
	size = rectangle
	_update_background()


## Update text using 'data' containing human-readable key-value pairs.
func update_text(data: Dictionary):
	data_label.text = ""
	for key in data.keys():
		var string = "[b]%-18s[/b] %s" % [key + ":", data[key]] + "\n"
		data_label.text += string


## Update the tile background.
func _update_background():
	var tiles = []
	for i in int(size.x / tile_size.x):
		for j in int(size.y / tile_size.y):
			tiles.append(Vector2i(i, j))
	text_bg.set_cells_terrain_connect(0, tiles, \
			TERRAINS.BACKGROUND.SET, TERRAINS.BACKGROUND.INDEX)
