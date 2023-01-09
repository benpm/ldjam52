extends Node

var gravity: float = 0.65
enum CollLayer {
	PLAYER = 0,
	DREAMS = 1,
	PLATFORM = 2,
	ENEMY = 3,
}

var score: int = 0
var high_score: int = 0

const nightmares = [
	preload("res://objects/nightmare_demon1.tscn"),
	preload("res://objects/nightmare_floater.tscn"),
	preload("res://objects/nightmare_snake.tscn"),
	preload("res://objects/nightmare_wasp.tscn"),
	preload("res://objects/nightmare_spider.tscn"),
]