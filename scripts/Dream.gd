extends AnimatedSprite

# The speed at which the object will float away
var float_speed = 15

# The distance at which the object will start floating away
var float_distance = 100

onready var xvel = rand_range(-2, 2)

var catching = false

onready var player = $"/root/scene/player"

func _process(delta):
	rotation += delta * 0.5
	position.y -= delta * float_speed
	position.x += xvel
	if catching:
		position = lerp(position, player.position, delta * 10.0)
		scale = lerp(scale, Vector2(0.1, 0.1), delta * 10.0)
		if position.distance_to(player.position) < 25:
			queue_free()
			player.dream += 1
