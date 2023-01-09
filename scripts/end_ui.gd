extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


onready var score_label: Label = $score

var display_score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.high_score = max(Game.high_score, Game.score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	display_score = int(ceil(lerp(display_score, Game.score, 0.1)))
	score_label.text = str(display_score)


func _on_retry_button_pressed() -> void:
	get_tree().change_scene("res://scenes/main.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().change_scene("res://scenes/menu.tscn")
