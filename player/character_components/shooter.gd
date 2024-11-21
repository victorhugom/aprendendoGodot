class_name Shooter extends Area2D

const PROJECTILE = preload("res://player/projectile.tscn")

@export var left_marker: Marker2D
@export var right_marker: Marker2D
@export var up_marker: Marker2D
@export var down_marker: Marker2D

## speed wich the projectile goes forward
@export var speed:= 36 * 5
## size of the projectile
@export var projectile_scale:= 1
## delay between shoots, only works if projectile count > 1
@export var shoot_interval:= 0.01

var projectile_config: ProjectileConfig

func shoot(direction: String, projectile_count: int, target_location: Vector2 = Vector2(0, 0)):
	
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
			
	_shoot(shoot_position, direction, target_location)
	
	if projectile_count > 1:
		var tween = get_tree().create_tween()
		tween.set_loops(projectile_count - 1)
		
		var shoot_callback = Callable(_shoot).bind(shoot_position, direction, target_location)
		tween.tween_callback(shoot_callback).set_delay(shoot_interval)

func _shoot(shoot_position: Vector2, direction: String, target_location:= Vector2(0, 0)):
	
	var projectile = PROJECTILE.instantiate()
	
	projectile.set_config(projectile_config)
	projectile.collision_layer = collision_layer
	projectile.collision_mask = collision_mask
	projectile.position = shoot_position  # Use the lock the position
	projectile.scale = Vector2(projectile_scale, projectile_scale)
	projectile.speed = speed
	
	get_tree().root.add_child(projectile)
	projectile.shoot(direction, target_location)
