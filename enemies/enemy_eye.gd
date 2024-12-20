class_name EnemyEye extends CharacterBody2D

const PROJECTILE_CONFIG = preload("res://player/projectile/enemyProjectile/enemy_eye_projectile.tres")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var player_trace_shape: ShapeCast2D = $PlayerTraceShape
@onready var player_trace_ray: RayCast2D = $PlayerTraceRay
@onready var tracking_timer: Timer = $NavigationAgent2D/TrackingTimer
@onready var shooter: Shooter = $Shooter
@onready var health_bar: HBoxContainer = $HealthBar
@onready var hurt_box: HurtBox = $HurtBox
@onready var hit_box: CollisionShape2D = $HitBox
@onready var health: Health = $Health

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

@export var target: Node
@export var speed: int
## Minimum distance where the enemy starts to track the player (in pixels), ie: only tracks the player if they are less than 200px far
@export var tracking_distance:= 250

var is_dying:= false
var is_attacking:= false
var direction:= "left"
var target_position: Vector2

func _ready() -> void:
	
	#health setup
	health.health_empty.connect(_on_health_empty)
	health_bar.health = health
	hurt_box.damaged.connect(_on_damaged)
	hurt_box.can_be_hurt = true
	
	add_to_group("enemies")
	
func can_update_char() -> bool:
	
	if target == null:
		return false
		
	if global_position.distance_to(target.global_position) > tracking_distance:
		return false
	
	if is_dying || animation_player.current_animation.begins_with("attack") || animation_player.current_animation.begins_with("hit"): 
		return false
		
	return true

func _physics_process(_delta: float) -> void:
	
	if target == null:
		target = Globals.player
	
	if can_update_char() == false:
		return
		
	if is_attacking:
		return
	
	var animation_type = "walk_"
	
	var next_path_position = navigation_agent_2d.get_next_path_position()
	var current_position = global_position
	velocity = current_position.direction_to(next_path_position) * speed
	
	var angle = atan2(velocity.y, velocity.x) # angle in [-PI, PI]
	if abs(angle) < 0.25 * PI:
		direction = "right"
		player_trace_shape.target_position = Vector2(0,300)
		player_trace_shape.rotation_degrees = -90
		player_trace_ray.target_position = Vector2(0,300)
		player_trace_ray.rotation_degrees = -90
	elif abs(angle) > 0.75 * PI:
		direction = "left"
		player_trace_shape.target_position = Vector2(0,-300)
		player_trace_shape.rotation_degrees = -90
		player_trace_ray.target_position = Vector2(0,-300)
		player_trace_ray.rotation_degrees = -90
	elif angle > 0.0:
		direction = "down"
		player_trace_shape.target_position = Vector2(0,300)
		player_trace_shape.rotation_degrees = 0
		player_trace_ray.target_position = Vector2(0,300)
		player_trace_ray.rotation_degrees = 0
	else:
		direction = "up"
		player_trace_shape.target_position = Vector2(0,-300)
		player_trace_shape.rotation_degrees = 0
		player_trace_ray.target_position = Vector2(0,-300)
		player_trace_ray.rotation_degrees = 0
		
	if is_seeing_player() and !is_attacking:
		# is already attacking don't need to start it
		prepare_attack()
	else:
		
		if velocity.length() > 0:
			animation_type = "walk_"
		else: #walking
			animation_type = "idle_"
			
		move_and_slide()
		animation_player.play(animation_type +  direction)


func follow_player() -> void:
	navigation_agent_2d.target_position = target.global_position

func update_target():
	target = Globals.player

func is_seeing_player() -> bool:
	
	if player_trace_ray.is_colliding():
		var collider = player_trace_ray.get_collider()
		if collider:
			if collider.name == "Wall":
				return false
			else:
				return true
	
	if player_trace_shape.is_colliding():
		var collider = player_trace_shape.get_collider(0)
		if collider:
			if collider.name == "Wall":
				return false
			else:
				return true
				
	return false
	
func _on_damaged() -> void:
	if is_dying: return
	animation_player.play("hit")

func _on_health_empty():
	
	is_dying = true
	hurt_box.set_deferred("monitoring", false)
	hurt_box.set_deferred("monitorable", false)
	
	hit_box.set_deferred("disabled", true)	

	animation_player.play("death")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()
	if anim_name.begins_with("attack"):
		if is_seeing_player():
			var tween = get_tree().create_tween()
			tween.tween_callback(prepare_attack).set_delay(.3)
		else:
			is_attacking = false
	else:
		is_attacking = false

## attacks if creature is not dying and player trace is colliding
func prepare_attack() -> void:
	
	if is_dying: 
		return
		
	if is_seeing_player():
		is_attacking = true
		target_position = Vector2(target.global_position.x, target.global_position.y - 16)
		animation_player.play("attack_" + direction)
	else:
		is_attacking = false
		
func _execute_attack():
	#execute attack during animation
	shooter.projectile_config = PROJECTILE_CONFIG
	shooter.shoot(direction, 1, target_position)

func _on_tracking_timer_timeout() -> void:
	if target != null:
		follow_player()
