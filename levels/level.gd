class_name Level extends Node2D

const PAUSE_SCREEN = preload("res://gui/pauseScreen.tscn")

@export var camera_zoom : float = 2

var pause_screen: PauseScreen
func _ready() -> void:
		Globals.camera_zoom = camera_zoom

func _input(event):
	if event is InputEventKey && event.keycode == KEY_M:
		var bus_idx = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_mute(bus_idx, true) # or false
	if event.is_action_released("ui_pause"):
		if pause_screen == null:
			pause_screen = PAUSE_SCREEN.instantiate()
			add_child(pause_screen)
