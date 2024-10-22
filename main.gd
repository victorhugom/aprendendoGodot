class_name MainScene extends Node2D

@onready var player: Player = %Player
@onready var customer_spawner: Node2D = $CustomerSpawner

@export var doors: Array[Node]

func _ready() -> void:
	customer_spawner.start()

func _exit_tree() -> void:
	customer_spawner.stop()
