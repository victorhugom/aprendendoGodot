class_name Enemy extends CharacterBody2D

const PROJECTILE_CONFIG = preload("res://player/projectile/enemyProjectile/enemy_eye_projectile.tres")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var eye: Sprite2D = $Eye
@onready var player_trace: ShapeCast2D = $PlayerTrace
@onready var tracking_timer: Timer = $NavigationAgent2D/TrackingTimer
@onready var shoot_timer: Timer = $ShootTimer
@onready var shooter: Shooter = $Shooter

@onready var hurt_box: HurtBox = $HurtBox
@onready var health: Health = $Health

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

@export var target: Node
@export var speed = 16*3

var is_dying = false
var direction = "left"
var is_seeing_player = false

func _ready() -> void:
	health.health_empty.connect(_on_health_empty)
	hurt_box.damaged.connect(_on_damaged)
	hurt_box.can_be_hurt = true
	
func _physics_process(_delta: float) -> void:
	
	if is_dying || animation_player.current_animation == "attack" || animation_player.current_animation == "hit": 
		return
		
	if global_position.distance_to(target.global_position) > 400:
		return
	
	is_seeing_player = player_trace.is_colliding()
	
	if is_seeing_player == false: #only moves if not seeing player
		var next_path_position = navigation_agent_2d.get_next_path_position()
		var current_position = global_position
		velocity = current_position.direction_to(next_path_position) * speed
		move_and_slide()
	
	if velocity.x < 0:
		eye.flip_h = false
		direction = "left"
		player_trace.target_position = Vector2(0,-300)
	else:
		player_trace.target_position = Vector2(0,300)
		direction = "right"
		eye.flip_h = true
		
	if velocity.x != 0:
		animation_player.play("walk_left")
	else:
		animation_player.play("idle_left")
		
func follow_player() -> void:
	navigation_agent_2d.target_position = target.global_position
	
func _on_damaged() -> void:
	if is_dying: return
	animation_player.play("hit")

func _on_health_empty():
	is_dying = true
	shoot_timer.stop()
	animation_player.play("death")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()

func _on_attack_timer_timeout() -> void:
	
	if is_dying: return
	
	if player_trace.is_colliding():
		animation_player.play("attack")
		
		shooter.projectile_config = PROJECTILE_CONFIG
		shooter.shoot(direction, 1)

func _on_tracking_timer_timeout() -> void:
	follow_player()
