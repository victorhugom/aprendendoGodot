class_name MainScene extends Node2D

func _ready() -> void:
	pass
	#if customer_spawner:
		#customer_spawner.start()

func _exit_tree() -> void:
	pass
	#if customer_spawner:
		#customer_spawner.stop()
