class_name MainScene extends Node2D

const PAUSE_SCREEN = preload("res://gui/pauseScreen.tscn")

var pause_screen: PauseScreen

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _input(event):
	if event is InputEventKey && event.keycode == KEY_M:
		var bus_idx = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_mute(bus_idx, true) # or false
	if event.is_action_released("ui_pause"):
		if pause_screen == null:
			pause_screen = PAUSE_SCREEN.instantiate()
			add_child(pause_screen)
		
