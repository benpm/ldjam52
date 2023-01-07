# Side-scrolling platformer player controller

extends KinematicBody2D

class_name Player

export(float) var maxfall: float = 16.0
export(float) var movespeed: float = 8.0
export(float) var jumpvel: float = 6
export(float) var catcher_point_speed: float = 0.05

onready var sprite: AnimatedSprite = $sprite
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
var catcher_point := Vector2.ZERO
var catching := false

func add_dream(amount):
	dream += amount

func _process(_delta: float) -> void:

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

	# Check if catcher line intersect with itself
	var intersection = false
	if not catching:
		for i in range(catcher_line.points.size() - 1):
			var a1 = catcher_line.points[i]
			var a2 = catcher_line.points[i + 1]
			for j in range(i + 2, catcher_line.points.size() - 1):
				var b1 = catcher_line.points[j]
				var b2 = catcher_line.points[j + 1]
				var d = Geometry.segment_intersects_segment_2d(a1, a2, b1, b2)
				if d != null:
					intersection = true
					break
			if intersection:
				Input.action_release("attack")
				catching = false
				catcher_line.clear_points()
				break
		
		# Check if line intersects with nightmares
		if catcher_line.points.size() > 0:
			for n in get_tree().get_nodes_in_group("nightmare"):
				var ext = Vector2.ZERO
				match n.shape.get_class():
					"RectangleShape2D":	
						ext = n.shape.extents
					"CircleShape2D":
						ext = Vector2(n.shape.radius, n.shape.radius)
				var bbox_points = [
					n.position + Vector2(-ext.x, -ext.y),
					n.position + Vector2(ext.x, -ext.y),
					n.position + Vector2(ext.x, ext.y),
					n.position + Vector2(-ext.x, ext.y)
				]
				print(n.get_class())
				if Geometry.intersect_polyline_with_polygon_2d(catcher_line.points, bbox_points):
					Input.action_release("attack")
					catching = false
					catcher_line.clear_points()
					n.health -= 1
					# n.vel += -(position - n.position).normalized() * 500
					break

	# Draw dreamcatcher path
	if not intersection and Input.is_action_pressed("attack") or catching:
		var mouse = get_global_mouse_position()
		
		var pts = catcher_line.points.size()
		# Set catcher point to mouse if no points exist
		catcher_point = mouse
		# Add new points for line as mouse is dragged
		if pts == 0 or catcher_point.distance_to(catcher_line.points[pts - 1]) > 10:
			catcher_line.add_point(catcher_point)

		# Check if distance to first point is close enough to close loop
		if (pts > 5 and catcher_point.distance_to(catcher_line.points[0]) < 25) or catching:
			# Slide catcher point to first point to close loop
			catcher_point = lerp(catcher_point, catcher_line.points[0], catcher_point_speed)
			catching = true
			# Catching is done when catcher point is close enough to first point
			if catcher_point.distance_to(catcher_line.points[0]) < 1:
				# Catch all dreams inside catcher line
				for d in get_tree().get_nodes_in_group("dream"):
					if not d.catching and Geometry.is_point_in_polygon(d.position, catcher_line.points):
						d.catching = true

				catcher_line.clear_points()
				catching = false
				Input.action_release("attack")
		else:
			catcher_point = lerp(catcher_point, mouse, catcher_point_speed)
	elif Input.is_action_just_released("attack"):
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
		if pvel.y > Game.gravity + 0.1:
			Sound.play("hit1", position)
		vel.y = 0
		jumps = 2
	else:
		vel.y += Game.gravity
	
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

func death():
	dead = true
	Sound.play("die", position)
	hide()
	# Global.game.player_died()

