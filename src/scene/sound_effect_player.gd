## SoundEffectPlayer controls sound effect playback.
class_name SoundEffectPlayer
extends Node


var streams = {
	"TILES_DROPPED": preload("res://asset/audio/blip.wav"),
}

var playback: AudioStreamPlaybackPolyphonic


# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer.play()
	playback = $AudioStreamPlayer.get_stream_playback()


## Play audio 'stream' with pitch scale in ['min_pitch', 'max_pitch'], time
## offset 'from_offset', and volume 'db'.
func play(stream: AudioStream, min_pitch: float = 1.0, max_pitch: float = 1.0,
		from_offset: float = 0.0, db: float = -20.0):
	playback.play_stream(stream, from_offset, db, randf_range(min_pitch, max_pitch))
