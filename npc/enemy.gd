class_name Enemy extends CharacterBody2D

const PROJECTILE = preload("res://player/projectile.tscn")
const PROJECTILE_CONFIG = preload("res://player/projectile/enemyProjectile/enemy_eye_projectile.tres")

@onready var animation_player: AnimationPlayer = $Enemy/AnimationPlayer
@onready var enemy: Sprite2D = $Enemy
@onready var player_trace: ShapeCast2D = $PlayerTrace
@onready var attack_timer: Timer = $AttackTimer
@onready var projectile_position: Node2D = $ProjectilePosition

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D
@onready var player: Player = %Player

@export var speed = 16*3

var life = 3
var is_dying = false
var direction = "left"
var is_seeing_player = false

var last_hit_knock_back_direction: Vector2
var last_hit_knock_back_power: int

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	
	if is_dying || animation_player.current_animation == "attack" || animation_player.current_animation == "hit": 
		return
	
	is_seeing_player = player_trace.is_colliding()
	
	if is_seeing_player == false: #only moves if not seeing player
		var next_path_position = navigation_agent_2d.get_next_path_position()
		var current_position = global_position
		velocity = current_position.direction_to(next_path_position) * speed
		move_and_slide()
	
	if velocity.x < 0:
		enemy.flip_h = false
		direction = "left"
		player_trace.target_position = Vector2(0,-300)
	else:
		player_trace.target_position = Vector2(0,300)
		direction = "right"
		enemy.flip_h = true
		
	if velocity.x != 0:
		animation_player.play("walk_left")
	else:
		animation_player.play("idle_left")
		
func follow_player() -> void:
	navigation_agent_2d.target_position = player.global_position
	
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
		animation_player.play("hit")

func knockBack(knock_back_direction: Vector2, knock_back_power: int):
	var knockBackDirection = (knock_back_direction-velocity).normalized() * knock_back_power
	velocity = knockBackDirection
	move_and_slide()
	
func delayed_knock_back():
	if last_hit_knock_back_direction.length() > 0:
		knockBack(last_hit_knock_back_direction, last_hit_knock_back_power)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()

func _on_attack_timer_timeout() -> void:
	
	if is_dying: return
	
	if player_trace.is_colliding():
		animation_player.play("attack")
		
		var projectile = PROJECTILE.instantiate()
		projectile.position = projectile_position.global_position
		
		if direction == "left":
			projectile.position.x -= 30
		elif direction == "right":
			projectile.position.x += 30
		
		projectile.set_config(PROJECTILE_CONFIG)
		
		get_parent().add_sibling(projectile)
		projectile.shoot(direction)

func _on_tracking_timer_timeout() -> void:
	follow_player()
