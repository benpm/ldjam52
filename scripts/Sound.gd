extends Node

var sounds = {}
const sound_files = {
	"catch": preload("res://sound/catch.wav"),
	"chime": preload("res://sound/chime.wav"),
	"jump": preload("res://sound/jump.wav"),
	"nightmare_attack": preload("res://sound/nightmare_attack.wav"),
	"nightmare_spawn": preload("res://sound/nightmare_spawn.wav"),
	"player_hurt": preload("res://sound/player_hurt.wav"),
	"run": preload("res://sound/run.wav"),
}

func _ready():
	for name in sound_files.keys():
		var stream: AudioStreamSample = sound_files[name]
		stream.loop_mode = AudioStreamSample.LOOP_DISABLED
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
	if sounds[name].stream.loop_mode != AudioStreamSample.LOOP_FORWARD:
		sounds[name].play()
		sounds[name].stream.loop_mode = AudioStreamSample.LOOP_FORWARD
	sounds[name].playing = true
	if pos != null:
		sounds[name].position = pos

func pause(name: String):
	sounds[name].playing = false
