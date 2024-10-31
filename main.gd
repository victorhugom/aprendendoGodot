class_name MainScene extends Node2D

func _ready() -> void:
	pass
	#if customer_spawner:
		#customer_spawner.start()

func _exit_tree() -> void:
	pass
	#if customer_spawner:
		#customer_spawner.stop()

func _input(event):
	if event is InputEventKey && event.keycode == KEY_M:
		var bus_idx = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_mute(bus_idx, true) # or false
