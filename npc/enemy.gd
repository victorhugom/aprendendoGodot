class_name Enemy extends "res://npc/npc.gd"

const PROJECTILE = preload("res://player/projectile.tscn")
const PROJECTILE_CONFIG = preload("res://player/projectile/enemy_eye_projectile.tres")

@onready var animation_player: AnimationPlayer = $Enemy/AnimationPlayer
@onready var enemy: Sprite2D = $Enemy
@onready var player_trace: ShapeCast2D = $PlayerTrace
@onready var attack_timer: Timer = $AttackTimer

var life = 3
var is_being_hit = false
var is_dying = false
var is_attacking = false
var direction = "left"

var last_hit_knock_back_direction: Vector2
var last_hit_knock_back_power: int

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
	
func damage(hurt_points: int, damage_type: Enums.ELEMENTS, knock_back_direction = Vector2(0,0), knock_back_power = 1500) -> void:
	
	if is_dying: return
	
	life -= hurt_points
	
	if knock_back_direction.length() > 0:
		last_hit_knock_back_direction = knock_back_direction
		last_hit_knock_back_power = knock_back_power
	
	if life <= 0:
		is_dying = true
		attack_timer.stop()
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
	
	if is_attacking || is_dying: return
	
	if player_trace.is_colliding() && is_being_hit == false:
		is_attacking = true
		animation_player.play("attack")
		
		var projectile = PROJECTILE.instantiate()
		projectile.position = global_position
		projectile.set_config(PROJECTILE_CONFIG)
		
		get_parent().add_sibling(projectile)
		projectile.shoot(direction)
		
func knockBack(knock_back_direction: Vector2, knock_back_power: int):
	var knockBackDirection = (knock_back_direction-velocity).normalized() * knock_back_power
	velocity = knockBackDirection
	move_and_slide()
	
func delayed_knock_back():
	if last_hit_knock_back_direction.length() > 0:
		knockBack(last_hit_knock_back_direction, last_hit_knock_back_power)
