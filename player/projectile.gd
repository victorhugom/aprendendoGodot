class_name Projectile extends Node2D

@onready var animation_player: AnimationPlayer = $BasicProjectile/AnimationPlayer
@onready var basic_projectile: Sprite2D = $BasicProjectile

var direction: Vector2
var started: bool
var speed = 36 * 5
var projectile_config: ProjectileConfig
var hit: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	animation_player.play("projectile_anim")
	
	if projectile_config.Id == Enums.PROJECTILE_ID.Common:
		basic_projectile.set_texture(preload("res://assets/player/basic_projectile-Sheet.png"))
	if projectile_config.Id == Enums.PROJECTILE_ID.Enemy_Eye:
		basic_projectile.set_texture(preload("res://assets/player/basic_projectile-Sheet.png"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hit: 
		return
	
	if started:
		position += direction.normalized() * speed * delta

func set_config(config: ProjectileConfig):
	projectile_config = config

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
	show_hit()

func _on_start_timer_timeout() -> void:
	visible = true
	started = true
	
func _on_area_entered(area: Area2D) -> void:
	
	var body = area.get_parent()
	if body is Enemy && projectile_config.Target == Enums.CHAR_TYPES.Enemy:
		(body as Enemy).damage(projectile_config.Damage, projectile_config.Element)
		show_hit()
	if body is Player && projectile_config.Target == Enums.CHAR_TYPES.Player:
		(body as Player).damage(projectile_config.Damage, projectile_config.Element)
		show_hit()

func _on_body_entered(body: Node2D) -> void:
	if body is Enemy || body is Player: return
	show_hit()
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "projectile_dismiss":
		queue_free()
		
func show_hit():
	hit = true
	animation_player.play("projectile_dismiss")
