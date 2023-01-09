extends Node2D


onready var overlay_rect: ColorRect = $"overlay_container/overlay_rect"
onready var tween: Tween = overlay_rect.get_node("Tween")


const nightmares = [
	preload("res://objects/nightmare_demon1.tscn"),
	preload("res://objects/nightmare_floater.tscn"),
	preload("res://objects/nightmare_snake.tscn"),
	preload("res://objects/nightmare_wasp.tscn"),
	preload("res://objects/nightmare_spider.tscn")
]

func _ready() -> void:
	$fx.show()
	for n in get_tree().get_nodes_in_group("bg_layer"):
		n.show()
	Game.score = 0
	overlay_rect.modulate = Color(0, 0, 0, 1)
	tween.interpolate_property(overlay_rect, "modulate", overlay_rect.modulate, Color(0, 0, 0, 0), 0.5)
	tween.start()

func fade_in(obj: Node, callback: String):
	tween.interpolate_property(overlay_rect, "modulate", overlay_rect.modulate, Color(0, 0, 0, 0), 0.5)
	if obj:
		get_tree().create_timer(0.5).connect("timeout", obj, callback)
	tween.start()

func fade_out(obj: Node, callback: String):
	tween.interpolate_property(overlay_rect, "modulate", overlay_rect.modulate, Color(0, 0, 0, 1), 0.5)
	if obj:
		get_tree().create_timer(0.5).connect("timeout", obj, callback)
	tween.start()

func goto_end_screen():
	get_tree().change_scene("res://scenes/end.tscn")
