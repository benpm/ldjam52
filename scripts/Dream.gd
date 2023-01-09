extends AnimatedSprite

# The speed at which the object will float away
var float_speed = 30

# The distance at which the object will start floating away
var float_distance = 100

var lifetime = 8.0
var warntime = 3.0

enum State {DEFAULT, DARKENING, TRANSFORMING, CATCHING}
var state = State.DEFAULT

onready var xvel = rand_range(-0.5, 0.5)

var t = 0

onready var r = rand_range(0, PI * 2)

onready var player = $"/root/scene/player"
onready var animator: AnimationPlayer = $AnimationPlayer

func _ready():
	animator.play("grow")

func _process(delta):
	t += delta
	if state != State.TRANSFORMING:
		position.y += delta * float_speed * sin(t * 0.1 + r) - 0.1
		position.x += xvel
	
	match state:
		State.DEFAULT:
			if t > lifetime:
				state = State.DARKENING
				animator.play("shake")
				play("darkening")
		State.DARKENING:
			speed_scale = 0.0
			frame = ceil((1.0 - ((t - lifetime) / lifetime)) * (frames.get_frame_count("darkening") - 1))
			if t > lifetime + warntime:
				state = State.TRANSFORMING
				frame = frames.get_frame_count("darkening") - 1
				animator.play("transform")
				var obj = Game.nightmares[rand_range(0, Game.nightmares.size()-1)].instance()
				obj.position = position
				$"/root/scene".call_deferred("add_child", obj)
		State.TRANSFORMING:
			pass
		State.CATCHING:
			position = lerp(position, player.position, delta * 5.0)
			scale = lerp(scale, Vector2(0.1, 0.1), delta * 5.0)
			if position.distance_to(player.position) < 25:
				queue_free()
				player.dream += 1
				Game.score += 1

func _on_AnimationPlayer_animation_finished(anim_name:String) -> void:
	if anim_name == "transform":
		queue_free()

func catch():
	if state == State.DEFAULT or state == State.DARKENING:
		state = State.CATCHING
		speed_scale = 1.0
		play("catching")