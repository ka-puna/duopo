## CycleValue manages a value that is set to a minimum value when it reaches or
## exceeds a maximum value.
class_name CycleValue


signal cycle_value_changed(value)
signal cycle_value_overflowed()


## The starting cycle value.
var start_value
## The maximum cycle value.
var max_value
var value: set = set_value

func _init(value_, start_value_, max_value_):
	start_value = start_value_
	max_value = max_value_
	value = value_


func set_value(value_):
	if value_ >= max_value:
		value = start_value
		cycle_value_overflowed.emit()
	else:
		value = value_
	cycle_value_changed.emit(value)
