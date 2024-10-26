class_name Projectile extends Node2D

@onready var animation_player: AnimationPlayer = $BasicProjectile/AnimationPlayer
@onready var basic_projectile: Sprite2D = $BasicProjectile

var direction: Vector2
var started: bool
var speed = 36 * 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	animation_player.play("projectile_anim")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if started:
		position += direction.normalized() * speed * delta

func shoot(player_direction: String) -> void:
	
	if player_direction == "left":
		direction = Vector2(-1,0)
		basic_projectile.flip_h = true
	elif player_direction == "right":
		direction = Vector2(1,0)
	elif player_direction == "up":
		direction = Vector2(0,-1)
		basic_projectile.rotation_degrees = -90
	elif player_direction == "down":
		direction = Vector2(0,1)
		basic_projectile.rotation_degrees = 90
			
func _on_destruction_timer_timeout() -> void:
	queue_free()

func _on_start_timer_timeout() -> void:
	visible = true
	started = true
