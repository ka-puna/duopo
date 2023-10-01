## This script controls the TileMap contained by the board scene.
extends TileMap

## The coordinate of the top-left tile of the pathable region.
@export var top_left = Vector2i(0, 8)
## The coordinate of the bottom-right tile of the pathable region.
@export var bottom_right = Vector2i(10, 18)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
