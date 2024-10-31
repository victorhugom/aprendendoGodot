class_name Shooter extends Area2D

const PROJECTILE = preload("res://player/projectile.tscn")

@export var left_marker: Marker2D
@export var right_marker: Marker2D
@export var up_marker: Marker2D
@export var down_marker: Marker2D

var projectile_config: ProjectileConfig

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func shoot(direction: String, projectile_count: int):
	
	var timer = Timer.new()
	timer.wait_time = 0.1
	
	for i in range(0, projectile_count):
		var projectile = PROJECTILE.instantiate()
		
		projectile.set_config(projectile_config)
		projectile.collision_layer = collision_layer
		projectile.collision_mask = collision_mask
		
		if direction == "left":
			projectile.position = left_marker.global_position
		elif direction == "right":
			projectile.position = right_marker.global_position
		elif direction == "up":
			projectile.position = up_marker.global_position
		elif direction == "down":
			projectile.position = down_marker.global_position
		
		get_tree().root.add_child(projectile)
		projectile.shoot(direction)
		
		timer.autostart = true
		await timer.timeout
