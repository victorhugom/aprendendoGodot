extends CharacterBody2D

@export var floor: Floor
@export var speed = 16*3

@onready var player: CharacterBody2D = %Player
@onready var timer: Timer = $Timer

var path: PackedVector2Array
var target_index = 0
var timed_out = false

func _ready() -> void:
	pass

			
func _physics_process(delta: float) -> void:
	
	if path.size() > 0:
		var target = path[target_index]
		var direction = (target - global_position).normalized()
		print_debug(direction)
		velocity = direction * speed
		move_and_slide()
		
		if global_position.distance_to(target) < 10:
			target_index += 1
			if target_index >= path.size():
				path.clear()
	
func _on_timer_timeout() -> void:
	update_path()
	
func update_path():
	
	var new_path = floor.recalculate_path2(self, player)
	
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
		target_index = 0
