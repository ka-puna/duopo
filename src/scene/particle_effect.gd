extends CPUParticles2D


signal expired(node: Node)

## The time before the particle effect expires in seconds.
@export var expire_time: float = 0.25
@onready var run_time: float = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	run_time += delta
	if run_time >= expire_time:
		expired.emit(self)
