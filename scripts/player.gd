# Side-scrolling platformer player controller

extends KinematicBody2D

class_name Player

export(float) var maxfall: float = 16.0
export(float) var movespeed: float = 8.0
export(float) var gravity: float = 0.35
export(float) var jumpvel: float = 6
export(float) var fixrate: float = 1.0
export(float) var attack_cooldown: float = 0.5
export(float) var catcher_point_speed: float = 0.05

onready var sprite: AnimatedSprite = $sprite
onready var attack_area: Area2D = $attack_area
onready var catcher_line: Line2D = $catcher_line_container/catcher_line

onready var initpos: Vector2 = position
var vel: Vector2 = Vector2(0, 0)
var pvel: Vector2
var jumps: int = 0
var on_one_way: bool
var landed: bool
var stepped: bool
var dead := false
var dream = 0
var can_attack := true
var attack_disable_nextframe := false
var catcher_point := Vector2.ZERO
var catching := false

func add_dream(amount):
	dream += amount

func _ready() -> void:
	disable_attack_area()

func _process(_delta: float) -> void:
	# Reset attack area
	if attack_area.monitoring:
		if attack_disable_nextframe:
			disable_attack_area()
			attack_disable_nextframe = false
		else:
			attack_disable_nextframe = true

	# Control animation
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
	# if abs(vel.x) > 0.1 and vel.y == 0.0:
	# 	Sounds.unpause("run", position)
	# else:
	# 	Sounds.pause("run", position)
	
	# World boundary
	# if position.y > maxy:
	# 	death()

	# Draw dreamcatcher path
	if Input.is_action_pressed("action") or catching:
		var mouse = get_global_mouse_position()
		var pts = catcher_line.points.size()
		if pts == 0:
			catcher_point = mouse
		if pts == 0 or catcher_point.distance_to(catcher_line.points[pts - 1]) > 10:
			catcher_line.add_point(catcher_point)
		if (pts > 5 and catcher_point.distance_to(catcher_line.points[0]) < 25) or catching:
			catcher_point = lerp(catcher_point, catcher_line.points[0], catcher_point_speed)
			catching = true
			if catcher_point.distance_to(catcher_line.points[0]) < 1:
				catcher_line.clear_points()
				catching = false
		else:
			catcher_point = lerp(catcher_point, mouse, catcher_point_speed)
	elif Input.is_action_just_released("action"):
		if not catching:
			catcher_line.clear_points()

func _physics_process(_delta: float) -> void:

	# Move left and right
	if Input.is_action_pressed("right"):
		vel.x = movespeed
	elif Input.is_action_pressed("left"):
		vel.x = -movespeed
	else:
		vel.x = 0
	
	# Set velocity to zero on ground
	if is_on_floor():
		if pvel.y > gravity + 0.1:
			Sound.play("hit1", position)
		vel.y = 0
		jumps = 2
	else:
		vel.y += gravity
	
	# Jump
	if Input.is_action_just_pressed("jump") and jumps > 0:
		vel.y = -jumpvel
		jumps -= 1
		sprite.speed_scale = 1
		sprite.play("jump")
		if jumps == 1:
			Sound.play("jump1", position)
		else:
			Sound.play("jump2", position)
	
	# Terminal velocity
	vel.y = min(vel.y, maxfall)

	# Fall through one-way platforms
	if Input.is_action_just_pressed("fall"):
		position.y += 2
		if vel.y != 0:
			vel.y = 6
	
	# Collision
	pvel = vel
	vel = move_and_slide(vel * 60, Vector2(0, -1)) / 60
	for i in get_slide_count():
		var col = get_slide_collision(i)
		if col.collider is TileMap:
			var t: TileMap = col.collider
			var p = t.world_to_map(col.position)
			var c = t.get_cell_autotile_coord(p.x, p.y)
			# if t.tile_set.is_damage_tile(c):
			# 	death()

func _input(event: InputEvent):
	if can_attack and event.is_action("attack"):
		enable_attack_area()
		can_attack = false
		var mouse = get_global_mouse_position()
		attack_area.rotation = position.angle_to_point(mouse) - PI / 2
		get_tree().create_timer(attack_cooldown).connect("timeout", self, "reset_attack")

func enable_attack_area():
	attack_area.monitoring = true
	attack_area.show()

func disable_attack_area():
	attack_area.monitoring = false
	attack_area.hide()

func reset_attack():
	can_attack = true

func death():
	dead = true
	Sound.play("die", position)
	hide()
	# Global.game.player_died()

# Attack area collision with enemy
func _on_attack_area_body_entered(body: Node):
	body.health -= 1
	print("hit nightmare")
	body.apply_impulse(Vector2.ZERO, -(position - body.position).normalized() * 1000)
