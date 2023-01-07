extends RigidBody2D

# The speed at which the object will float away
var float_speed = 100

# The distance at which the object will start floating away
var float_distance = 100

onready var shape: Shape2D = $CollisionShape2D.shape
onready var player = $"/root/scene/player"

func _physics_process(delta):
	# Get the distance between the player and this object
	var distance = position.distance_to(player.position)
	
	# If the player is within the float distance, float away
	if distance < float_distance:
		# Calculate the direction to float in
		var float_direction = (position + player.position).normalized()
		var float_velocity = float_direction * float_speed
		set_linear_velocity(float_velocity)
		rotation += 1
# If the player touches the dream it disappears
func _on_Dream_body_entered(body):
	body.add_dream()
	queue_free()
