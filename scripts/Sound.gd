extends Node

var sounds = {}
const sound_files = {
	"catch": preload("res://sound/catch.ogg"),
	"chime": preload("res://sound/chime.ogg"),
	"jump": preload("res://sound/jump.ogg"),
	"nightmare_attack": preload("res://sound/nightmare_attack.ogg"),
	"nightmare_spawn": preload("res://sound/nightmare_spawn.ogg"),
	"player_hurt": preload("res://sound/player_hurt.ogg"),
	"run": preload("res://sound/run.ogg"),
	"collect": preload("res://sound/collect.ogg"),
	"hit": preload("res://sound/hit.ogg"),
}

func _ready():
	for name in sound_files.keys():
		var stream: AudioStreamOGGVorbis = sound_files[name]
		stream.loop = false
		var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		player.name = name
		player.stream = stream
		player.autoplay = false
		player.bus = "SFX"
		player.attenuation = 2.0
		sounds[name] = player
		add_child(player)

func play(name: String, pos: Vector2):
	sounds[name].stop()
	if pos != null:
		sounds[name].position = pos
	sounds[name].play()

func unpause(name: String, pos: Vector2):
	if not sounds[name].stream.loop:
		sounds[name].play()
		sounds[name].stream.loop = true
	if not sounds[name].playing:
		sounds[name].playing = true
	if pos != null:
		sounds[name].position = pos

func pause(name: String):
	sounds[name].playing = false
