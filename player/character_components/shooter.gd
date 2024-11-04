class_name Shooter extends Area2D

const PROJECTILE = preload("res://player/projectile.tscn")

@onready var timer: Timer = $Timer

@export var left_marker: Marker2D
@export var right_marker: Marker2D
@export var up_marker: Marker2D
@export var down_marker: Marker2D
@export var shoot_delay: float = 0.1

var projectile_config: ProjectileConfig

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = shoot_delay

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func shoot(direction: String, projectile_count: int, projectile_scale: int = 1, target_location: Vector2 = Vector2(0,0)):
	
	
	for i in range(0, projectile_count):
		var projectile = PROJECTILE.instantiate()
		
		projectile.set_config(projectile_config)
		projectile.collision_layer = collision_layer
		projectile.collision_mask = collision_mask
		projectile.scale = Vector2(projectile_scale, projectile_scale)
		
		if direction == "left":
			projectile.position = left_marker.global_position
		elif direction == "right":
			projectile.position = right_marker.global_position
		elif direction == "up":
			projectile.position = up_marker.global_position
		elif direction == "down":
			projectile.position = down_marker.global_position
		
		get_tree().root.add_child(projectile)
		projectile.shoot(direction, target_location)
		
		timer.start()
		await timer.timeout
