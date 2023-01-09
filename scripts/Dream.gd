extends AnimatedSprite

# The speed at which the object will float away
var float_speed = 30

# The distance at which the object will start floating away
var float_distance = 100

const deftime = 8.0
const warntime = 3.0
const lifetime = deftime + warntime

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
			if t > deftime:
				state = State.DARKENING
				animator.play("shake")
				play("darkening")
		State.DARKENING:
			speed_scale = 0.0
			frame = floor(((t - deftime) / warntime) * frames.get_frame_count("darkening"))
			if t > lifetime:
				speed_scale = 1.0
				state = State.TRANSFORMING
				play("transforming")
				animator.play("transform")
				var n = $"/root/scene".nightmares
				var obj = n[rand_range(0, n.size()-1)].instance()
				obj.position = position
				$"/root/scene".call_deferred("add_child", obj)
				Sound.play("nightmare_spawn", position)
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
		get_tree().create_timer(rand_range(0.0, 0.3)) \
			.connect("timeout", Sound, "play", ["collect", position])
