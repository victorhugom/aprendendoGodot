class_name Enemy extends "res://npc/npc.gd"

const PROJECTILE = preload("res://player/projectile.tscn")

@onready var animation_player: AnimationPlayer = $Enemy/AnimationPlayer
@onready var enemy: Sprite2D = $Enemy
@onready var player_trace: ShapeCast2D = $PlayerTrace
@onready var attack_timer: Timer = $AttackTimer

var life = 3
var is_being_hit = false
var is_dying = false
var is_attacking = false
var direction = "left"

func _ready() -> void:
	super._ready()
	track_node(%Player)
	
func _physics_process(delta: float) -> void:
	
	if is_dying || is_being_hit || is_attacking: 
		return
	
	super._physics_process(delta)
	
	if velocity.x < 0:
		enemy.flip_h = false
		direction = "left"
		player_trace.target_position = Vector2(0,-300)
	else:
		player_trace.target_position = Vector2(0,300)
		direction = "right"
		enemy.flip_h = true
		
	if is_being_hit: return
	
	if velocity.x != 0:
		animation_player.play("walk_left")
	else:
		animation_player.play("idle_left")
	
func damage(hurt_points: int, damage_type: Enums.ELEMENTS) -> void:
	
	if is_dying || is_being_hit: return
	
	life -= hurt_points
	
	if life <= 0:
		is_dying = true
		animation_player.play("death")
	else:
		is_being_hit = true
		animation_player.play("hit")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hit":
		is_being_hit = false
	if anim_name == "death":
		queue_free()
	if anim_name == "attack":
		is_attacking = false

func _on_attack_timer_timeout() -> void:
	
	if is_attacking: return
	
	if player_trace.is_colliding() && is_being_hit == false:
		is_attacking = true
		animation_player.play("attack")
		
		var projectile = PROJECTILE.instantiate()
		projectile.position = global_position
		projectile.set_config(preload("res://player/projectile/enemy_eye_projectile.tres"))
		
		get_parent().add_sibling(projectile)
		projectile.shoot(direction)
