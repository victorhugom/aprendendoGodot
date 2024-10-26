class_name MainScene extends Node2D

@onready var player: Player = %Player
#@onready var customer_spawner: Node2D = $CustomerSpawner

func _ready() -> void:
	pass
	#if customer_spawner:
		#customer_spawner.start()

func _exit_tree() -> void:
	pass
	#if customer_spawner:
		#customer_spawner.stop()
