extends AnimatedSprite

enum State {OFF, ON, ZZZ};
var state = State.OFF

onready var particles: CPUParticles2D = $CPUParticles2D
const dream_packed: PackedScene = preload("res://objects/Dream.tscn")

func _ready():
	particles.emitting = false

func set_state(state):
	self.state = state
	match state:
		State.OFF:
			self.frame = 0
			particles.emitting = false
		State.ON:
			self.frame = 1
		State.ZZZ:
			self.frame = 0
			particles.emitting = true
	
func _on_Timer_timeout():
	if state == State.OFF and randf() < 0.1:
		set_state(State.ON)
	elif state == State.ON and randf() < 0.25:
		set_state(State.ZZZ)
	elif state == State.ZZZ and randf() < 0.25:
		set_state(State.OFF)
		var obj = dream_packed.instance()
		obj.position = position
		$"/root/scene".call_deferred("add_child", obj)
