## SoundEffectPlayer controls sound effect playback.
class_name SoundEffectPlayer
extends Node


var SOUNDS = {
	"TILES_DROPPED": "BLIP",
	"PATH_UPDATED": "BLIP2",
}


## Plays the AudioStreamPlayer with the name 'node'.
func play(node: String):
	var audio_stream_player = get_node_or_null(node)
	if audio_stream_player:
		audio_stream_player.play()
