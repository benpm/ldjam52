extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player: Player = $"/root/scene/player"

# Called when the node enters the scene tree for the first time.
func _ready():
	limit_bottom = $"/root/scene/bottom_boundary".position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = player.position
