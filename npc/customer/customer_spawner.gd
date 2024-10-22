extends Node2D

const CUSTOMER = preload("res://npc/customer/customer.tscn")

@export var root_node: Node2D
@export var level_floor: TileMapLayer
@export var spawn_interval: float = 10:
	get:
		return spawn_interval
	set(value):
		timer.set_wait_time(spawn_interval)

@onready var timer: Timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	_create_customer()

func _create_customer():
	var new_customer = CUSTOMER.instantiate()
	new_customer.level_floor = level_floor
	new_customer.global_position = global_position
	
	root_node.add_child(new_customer)
	
func start() -> void:
	timer.start()
	
func stop() -> void:
	timer.stop()
