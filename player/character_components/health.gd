class_name Health extends Node2D

signal health_empty
signal health_changed(health: int)

@export_range(1, 999) var max_health: int
var current_health: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func decrease_health(value: int = 1) -> bool:
	
	if current_health <= 0:
		health_empty.emit()
		print_debug("Health: Try Descreased Health: No health to loose")
		return false
		
	current_health -= value
	print_debug("Health: Descreased Health by %s: current health: %s" % [value, current_health])
	health_changed.emit(current_health)
	
	if current_health <= 0:
		health_empty.emit()
		
	return true

func increase_health(value: int = 1) -> bool:
	
	if current_health >= max_health: 
		print_debug("Health: Try increased Health: Max health")
		return false
	
	current_health += value
	health_changed.emit(current_health)
	print_debug("Health: Increase Health by %s: current health: %s" % [value, current_health])
	
	return true
	
