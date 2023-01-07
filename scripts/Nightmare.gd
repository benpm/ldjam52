extends RigidBody2D

export (int) var health := 100

# The speed at which the object will float away
var float_speed = 100

# The distance at which the object will start floating away
var float_distance = 100

onready var player = $"/root/scene/player"

func _physics_process(delta):
	# Get the distance between the player and this object
	var distance = position.distance_to(player.position)
	
	# If the player is within the float distance, float away
	if distance < float_distance:
		# Calculate the direction to float in
		var float_direction = (position - player.position).normalized()
		
		# Apply a force in the float direction
		apply_impulse(Vector2.ZERO, -float_direction * float_speed)
		
		# Rotate slightly as the object floats away
		rotation += 1
