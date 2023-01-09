extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

onready var bg: TextureRect = $bg

var t = 0
onready var ipos = rect_position
onready var score_label: Label = find_node("score")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Game.high_score > 0:
		score_label.text = "%d" % Game.high_score


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t += delta
	bg.rect_position.x = -1000 + sin(t * 0.25) * 250
	bg.rect_position.y = -1000 + cos(t * 0.25) * 250


func _on_play_button_pressed() -> void:
	get_tree().change_scene("res://scenes/main.tscn")
