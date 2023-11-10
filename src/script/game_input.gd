## GameInput processes user input, including mouse and keyboard.
class_name GameInput


signal tile_action(action, state, delta)
signal tile_selection(tile)


enum ACTION_STATE {JUST_PRESSED, PRESSED, JUST_RELEASED}
var actions: Array[StringName]
var board: TileMapCustom
## The layer to search for inbound tiles.
var inbound_layer: int


func _init(board_, inbound_layer_):
	board = board_
	inbound_layer = inbound_layer_
	update_actions()


## Processes an input 'event'.
func input(event: InputEvent):
	if event is InputEventMouse:
		var mouse_tile = board.local_to_map(board.get_local_mouse_position())
		# If tile is within bounds.
		if board.get_cell_tile_data(inbound_layer, mouse_tile):
			tile_selection.emit(mouse_tile)


## Processes a polled input with 'delta' time elapsed.
func process(delta: float):
	# Exclude out-of-bounds mouse actions.
	if Input.get_mouse_button_mask() != 0:
		var mouse_tile = board.local_to_map(board.get_local_mouse_position())
		if not board.get_cell_tile_data(inbound_layer, mouse_tile):
			return
	# Process user action.
	for action in actions:
		if Input.is_action_pressed(action, true):
			if Input.is_action_just_pressed(action, true):
				tile_action.emit(action, ACTION_STATE.JUST_PRESSED, delta)
			else:
				tile_action.emit(action, ACTION_STATE.PRESSED, delta)
		if Input.is_action_just_released(action,true):
			tile_action.emit(action, ACTION_STATE.JUST_RELEASED, delta)


## Updates the array of actions.
func update_actions():
	var list = InputMap.get_actions()
	list = list.filter(func(s): return s.begins_with("game_"))
	actions = list
