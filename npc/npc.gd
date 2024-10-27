extends CharacterBody2D

signal found_target

@export var level_floor: Floor
@export var speed = 16*3
@export var track_distance = 16*3
@export var stop = false

@onready var tracking_timer: Timer = $TrackingTimer

var target_node: Node2D
var tracking_node: bool
var target_path_index = 0
var path: PackedVector2Array

func _ready() -> void:
	print_debug(Time.get_time_string_from_system(), ": new npc ready")
	
func _physics_process(_delta: float) -> void:
	if path.size() > 0:
		_follow_path()
		
func track_node(target: Node2D):
	# set node that will be followed
	
	tracking_node = true
	target_node = target
	tracking_timer.start()

func _on_tracking_timer_timeout() -> void:
	_get_path(target_node.global_position)

func _follow_path():
	
	if path.size() > 0 && stop == false:
		
		var target_path = path[target_path_index]
		var direction = (target_path - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		
		if global_position.distance_to(target_path) < track_distance:
			target_path_index += 1
			if target_path_index >= path.size():
				path.clear()
				found_target.emit()

func _get_path(target_position: Vector2):

	#no path to calculate is close enough
	if global_position.distance_to(target_position) < track_distance: 
		return
	
	var new_path = level_floor.recalculate_path(self.global_position, target_position)
	target_path_index = 0
	
	if new_path.size() > 0:
		# Interpolate the path update
		var current_position = global_position
		var next_position = new_path[0]
		var interpolated_position = current_position.lerp(next_position, 0.5)
		
		# Convert PackedVector2Array to Array
		var new_path_array = []
		for point in new_path:
			new_path_array.append(point)
		
		# Update the path with the interpolated position
		path = [interpolated_position] + new_path_array.slice(1, new_path_array.size())
		target_path_index = 0
	else:
		path = []
	
func go_to_location(location: Vector2):
	_get_path(location)
