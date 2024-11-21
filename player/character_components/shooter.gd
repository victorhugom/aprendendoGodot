class_name Shooter extends Area2D

const PROJECTILE = preload("res://player/projectile.tscn")

@onready var timer: Timer = $Timer

@export var left_marker: Marker2D
@export var right_marker: Marker2D
@export var up_marker: Marker2D
@export var down_marker: Marker2D
## delay between shoots, only works if projectile count > 1
@export var shoot_interval: float = 0.1:
	set(value):
		timer.wait_time = value
	get:
		return shoot_interval

var projectile_config: ProjectileConfig

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = minf(0.1, shoot_interval)

func shoot(direction: String, projectile_count: int, projectile_scale: int = 1, target_location: Vector2 = Vector2(0, 0)):
	# Determine the position based on the direction at the time of shooting
	var shoot_position: Vector2
	match direction:
		"left":
			shoot_position = left_marker.global_position
		"right":
			shoot_position = right_marker.global_position
		"up":
			shoot_position = up_marker.global_position
		"down":
			shoot_position = down_marker.global_position
	
	for i in range(projectile_count):
		var projectile = PROJECTILE.instantiate()
		
		projectile.set_config(projectile_config)
		projectile.collision_layer = collision_layer
		projectile.collision_mask = collision_mask
		projectile.scale = Vector2(projectile_scale, projectile_scale)
		projectile.position = shoot_position  # Use the locked position
		
		get_tree().root.add_child(projectile)
		projectile.shoot(direction, target_location)
		
		timer.start()
		await timer.timeout
