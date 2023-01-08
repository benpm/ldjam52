extends KinematicBody2D

export (int) var health := 100
enum MoveType {FLOAT, RUN, FLY}
export(MoveType) var move_type := MoveType.FLOAT
export (float) var move_speed := 20.0
export(float) var jumpvel: float = 6
export (bool) var has_gravity: bool = true

# The distance at which the object will start floating away
var float_distance = 1000

var vel: Vector2 = Vector2(0, 0)
var jumps: int = 2
var pvel: Vector2
var dojump: bool = false
var stepped: bool
var attack_timer: float = 0.5
var stun_timer: float = 0.0

onready var player: Player = $"/root/scene/player"
onready var shape = $CollisionShape2D.shape
onready var sprite: AnimatedSprite = $AnimatedSprite
onready var animator: AnimationPlayer = $AnimationPlayer

func _ready():
	add_to_group("nightmare")
	layers = 0
	collision_mask = 0
	# set_collision_layer_bit(Game.CollLayer.ENEMY, true)
	set_collision_mask_bit(Game.CollLayer.PLATFORM, true)

func _process(delta):
	if stun_timer > 0.0:
		stun_timer -= delta
		vel.x = 0
	elif position.distance_to(player.position) < 30:
		vel = Vector2.ZERO
		attack_timer -= delta
		if attack_timer <= 0:
			attack_timer = 0.5
			attack()
	else:
		attack_timer -= delta
		if attack_timer <= 0.0:
			attack_timer = 0.5
			match move_type:
				MoveType.FLOAT:
					move_float()
				MoveType.RUN:
					move_run()
				MoveType.FLY:
					move_fly()
	
	if health <= 0:
		# If the object has no health, destroy it
		queue_free()

func attack():
	sprite.play("attack")
	if position.distance_to(player.position) < 30:
		player.health -= 1
		player.animator.play("blink")

func attacked(dmg):
	health -= dmg
	animator.play("blink")
	animator.playback_speed = 2
	stun_timer = 0.5

func _physics_process(_delta: float) -> void:
	# Control animation
	match move_type:
		MoveType.RUN:
			if abs(pvel.y) < 0.1:
				if sprite.animation != "run":
					sprite.animation = "run"
				sprite.speed_scale = abs(pvel.x / 3)
				if pvel.x == 0:
					sprite.frame = 0
				if sprite.frame == 1 and not stepped:
					stepped = true
				elif sprite.frame != 1:
					stepped = false
			elif pvel.y > 0.1:
				sprite.animation = "fall"
			if abs(pvel.x) > 0:
				sprite.flip_h = pvel.x < 0
		MoveType.FLOAT:
			sprite.animation = "float"
		MoveType.FLY:
			sprite.animation = "fly"
		
	# Set velocity to zero on ground
	if has_gravity:
		if is_on_floor():
			if pvel.y > Game.gravity + 0.1:
				Sound.play("hit1", position)
			vel.y = 0
			jumps = 2
		else:
			vel.y += Game.gravity
	
		# Jump
		if jumps > 0 and dojump:
			vel.y = -jumpvel
			jumps -= 1
			sprite.speed_scale = 1
			sprite.play("jump")
			dojump = false
			if jumps == 1:
				Sound.play("jump1", position)
			else:
				Sound.play("jump2", position)
	
	# Collision
	pvel = vel
	vel = move_and_slide(vel * 60, Vector2(0, -1)) / 60

func move_float():
	# Get the distance between the player and this object
	var distance = position.distance_to(player.position)
	
	# If the player is within the float distance, float away
	if distance < float_distance:
		# Calculate the direction to float in
		var float_direction = (position - player.position).normalized()
		
		# Apply a force in the float direction
		vel = -float_direction * move_speed
		
		# Rotate slightly as the object floats away
		sprite.rotation += 1

func move_run():
	# Get the direction to the player
	var direction = (player.position - position).normalized()
	
	# Apply a force in the direction
	if is_on_floor():
		vel.x = sign(direction.x) * move_speed

	if player.position.y < position.y - 100:
		dojump = true

func move_fly():
	# Get the distance between the player and this object
	var distance = position.distance_to(player.position)
	
	# If the player is within the float distance, float away
	if distance < float_distance:
		# Calculate the direction to float in
		var float_direction = (position - player.position).normalized()
		
		# Apply a force in the float direction
		vel = vel.linear_interpolate(-float_direction * move_speed, 0.25)

		sprite.rotation = vel.angle()
		sprite.play("fly")
