extends Node2D


onready var overlay_rect: ColorRect = $"overlay_container/overlay_rect"
onready var tween: Tween = overlay_rect.get_node("Tween")

func _ready() -> void:
	$fx.show()
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
