extends Node

var player: Node

var next_scence_path := "res://levels/main.tscn"
var previous_scence_path:= "res://levels/main.tscn"
var loading_screen := preload("res://gui/loadingScreen.tscn")
var camera_zoom : float = 2.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_full_screen"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
