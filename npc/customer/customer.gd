class_name Customer extends "res://npc/npc.gd"

var my_chair: Chair

@export var is_sitting: bool:
	set(value):
		if value:
			path.clear() #clear path to no run anymore
			
		is_sitting = value

func _ready() -> void:
	super._ready()
	
func _find_chair():
	var chairs = Helper.get_all_nodes_of_subtype(get_tree().root, Chair)
	var empty_chairs = chairs.filter(func(x): return x.is_empty)
	
	if empty_chairs.size() > 0:
		my_chair = empty_chairs[randi_range(0, empty_chairs.size() - 1)]
		my_chair.is_empty = false
		go_to_location(my_chair.global_position)
	else:
		_wander()
		print_debug("not chair for me")
		
func _wander():
	var random_point = level_floor.get_points_in_radius(global_position, 16 * 8)
	go_to_location(random_point)

func _on_wander_timer_timeout() -> void:
	if my_chair: return
	_find_chair()
