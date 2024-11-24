extends Node2D

@onready var audio_stream_player_2d_amibent: AudioStreamPlayer = $AudioStreamPlayer2D_AMIBENT
@onready var audio_stream_player_2d_music: AudioStreamPlayer = $AudioStreamPlayer2D_MUSIC


func play():
	audio_stream_player_2d_amibent.play()
	audio_stream_player_2d_music.play()
	
func stop():
	audio_stream_player_2d_amibent.stop()
	audio_stream_player_2d_music.stop()
