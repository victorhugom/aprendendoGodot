class_name Projectile extends Area2D

@onready var animation_player: AnimationPlayer = $BasicProjectile/AnimationPlayer
@onready var basic_projectile: Sprite2D = $BasicProjectile

var direction: Vector2
var speed = 36 * 5
var projectile_config: ProjectileConfig
var hit: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("projectile_anim")
	basic_projectile.set_texture(projectile_config.projectileTexture)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hit: 
		return
	
	position += direction.normalized() * speed * delta

func set_config(config: ProjectileConfig):
	projectile_config = config

func shoot(player_direction: String, target_location: Vector2 = Vector2(0,0)) -> void:
	
	if player_direction == "left":
		direction = Vector2(-1,0)
		basic_projectile.flip_h = true
	elif player_direction == "right":
		direction = Vector2(1,0)
	elif player_direction == "up":
		direction = Vector2(0,-1)
		rotation_degrees = -90
	elif player_direction == "down":
		direction = Vector2(0,1)
		rotation_degrees = 90
	
	if(target_location.length() > 0):
		look_at(target_location)
		basic_projectile.flip_h = false
		direction = (target_location + Vector2(16,0) - global_position).normalized()
			
func _on_destruction_timer_timeout() -> void:
	show_hit()

func _on_area_entered(_area: Area2D) -> void:
	show_hit()

func _on_area_shape_entered(_area_rid: RID, _area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	show_hit()

func _on_body_shape_entered(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	show_hit()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "projectile_dismiss":
		queue_free()
		
func show_hit():
	hit = true
	animation_player.play("projectile_dismiss")
