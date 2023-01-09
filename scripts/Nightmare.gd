extends KinematicBody2D

export (int) var health := 100
enum MoveType {FLOAT, RUN, FLY}
export(MoveType) var move_type := MoveType.FLOAT
export (float) var move_speed := 20.0
export(float) var jumpvel: float = 6
export (bool) var has_gravity: bool = true
export (bool) var rotate_dir: bool = false
export (float) var attack_freq: float = 0.5

# The distance at which the object will start floating away
var float_distance = 1000

var vel: Vector2 = Vector2(0, 0)
var jumps: int = 2
var pvel: Vector2
var dojump: bool = false
var stepped: bool
var attack_timer: float = 0.5
var stun_timer: float = 0.0

var min_attack_dist: float = 60

onready var player = $"/root/scene/player"
onready var shape = $CollisionShape2D.shape
onready var sprite: AnimatedSprite = $AnimatedSprite
onready var animator: AnimationPlayer = $AnimationPlayer

const dream_packed: PackedScene = preload("res://objects/Dream.tscn")

func _ready():
	add_to_group("nightmare")
	layers = 0
	collision_mask = 0
	match move_type:
		MoveType.RUN:
			sprite.play("run")
		MoveType.FLOAT:
			sprite.play("float")
		MoveType.FLY:
			sprite.play("fly")
	set_collision_layer_bit(Game.CollLayer.ENEMY, true)
	set_collision_mask_bit(Game.CollLayer.PLATFORM, true)

func _process(delta):
	if stun_timer > 0.0:
		stun_timer -= delta
		if has_gravity:
			vel.x = 0
		else:
			vel = Vector2.ZERO
	elif position.distance_to(player.position) < min_attack_dist:
		vel = Vector2.ZERO
		attack_timer -= delta
		sprite.animation = "attack"
		sprite.frame = floor((attack_timer / attack_freq) * sprite.frames.get_frame_count("attack"))
		if attack_timer <= 0:
			attack()
	else:
		# Complete attack
		attack_timer -= delta
		if attack_timer <= 0.0:
			attack_timer = attack_freq
			match move_type:
				MoveType.FLOAT:
					sprite.animation = "float"
					move_float()
				MoveType.RUN:
					move_run()
				MoveType.FLY:
					sprite.animation = "fly"
					move_fly()
	
	if health <= 0:
		# If the object has no health, destroy it
		death()

func attack():
	attack_timer = attack_freq
	sprite.speed_scale = 1
	Sound.play("nightmare_attack", position)
	if position.distance_to(player.position) < min_attack_dist:
		player.attacked(1)
		Sound.play("player_hurt", position)

func attacked(dmg):
	health -= dmg
	animator.play("blink")
	animator.playback_speed = 3
	stun_timer = 0.25
	sprite.stop()

func _physics_process(_delta: float) -> void:
	# Control animation
	match move_type:
		MoveType.RUN:
			if abs(vel.y) < 0.1:
				if sprite.animation != "run":
					sprite.animation = "run"
				sprite.speed_scale = abs(vel.x / 3)
				if vel.x == 0:
					sprite.frame = 0
				if sprite.frame == 1 and not stepped:
					stepped = true
				elif sprite.frame != 1:
					stepped = false
			elif vel.y > 0.1:
				sprite.animation = "fall"
			if abs(vel.x) > 0:
				sprite.flip_h = vel.x < 0
		MoveType.FLOAT:
			pass
		MoveType.FLY:
			pass
		
	# Set velocity to zero on ground
	if has_gravity:
		if is_on_floor():
			if pvel.y > Game.gravity + 0.1:
				vel.x = 0
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
				Sound.play("jump", position)
			else:
				Sound.play("jump", position)
	
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
	else:
		vel = Vector2.ZERO

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

		if rotate_dir:
			sprite.rotation = vel.angle()
		else:
			sprite.flip_h = float_direction.x > 0
		sprite.play("fly")

func death():
	var particles: CPUParticles2D = $"/root/scene/fx/star_particles"
	particles.position = position
	particles.one_shot = true
	particles.emitting = true
	particles.restart()
	var obj = dream_packed.instance()
	obj.position = position
	$"/root/scene".call_deferred("add_child", obj)
	queue_free()
