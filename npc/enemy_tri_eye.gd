class_name EnemyTriEye extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var tracking_timer: Timer = $NavigationAgent2D/TrackingTimer
@onready var attack_timer: Timer = $AttackTimer

@onready var hurt_box: HurtBox = $HurtBox
@onready var health: Health = $Health

@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

@export var target: Node
@export var speed = 16*3

var is_dying = false
var direction = "left"
var target_position: Vector2

func _ready() -> void:
	health.health_empty.connect(_on_health_empty)
	hurt_box.damaged.connect(_on_damaged)
	hurt_box.can_be_hurt = true
	
	tracking_timer.connect("timeout", _on_tracking_timer_timeout)
	attack_timer.connect("timeout", _on_attack_timer_timeout)
	add_to_group("enemies")
	
func can_update_char():
	
	if target == null: 
		return false
	
	if is_dying || animation_player.current_animation.begins_with("attack") || animation_player.current_animation.begins_with("hit"): 
		return false
		
	return true

func _physics_process(_delta: float) -> void:
	
	if can_update_char() == false:
		return
	
	var animation_type = "walk_"
	
	if global_position.distance_to(target.global_position) > 16:
		
		if attack_timer.is_stopped() == false: attack_timer.stop()
		
		var next_path_position = navigation_agent_2d.get_next_path_position()
		var current_position = global_position
		velocity = current_position.direction_to(next_path_position) * speed
		move_and_slide()
	else:
		if attack_timer.is_stopped(): attack_timer.start()
		velocity = Vector2(0,0)
	
	var angle = atan2(velocity.y, velocity.x) # angle in [-PI, PI]
	if abs(angle) < 0.25 * PI:
		direction = "right"
	elif abs(angle) > 0.75 * PI:
		direction = "left"
	#elif angle > 0.0:
		#direction = "down"
	#else:
		#direction = "up"

	if velocity.length() > 0:
		animation_type = "walk_"
	else: #walking
		animation_type = "idle_"

	animation_player.play(animation_type +  direction)
	
		
func follow_player() -> void:
	#navigation_agent_2d.target_position = target.global_position
	
	var direction_to_player = target.global_position - global_position 
	var horizontal_target_pos = global_position 
	var side_offset = 16 # Distance to the left or right of the player
	if direction_to_player.x > 0: 
		# Move to the left side of the player 
		horizontal_target_pos = target.global_position - Vector2(side_offset, 0) 
	else: # Move to the right side of the player 
		horizontal_target_pos = target.global_position + Vector2(side_offset, 0) 
		
	navigation_agent_2d.set_target_position(horizontal_target_pos)

func update_target():
	target = Globals.player
	
func _on_damaged() -> void:
	if is_dying: return
	animation_player.play("hit")

func _on_health_empty():
	is_dying = true
	attack_timer.stop()
	animation_player.play("death")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()

func _on_attack_timer_timeout() -> void:
	
	if is_dying: return
	
	target_position = target.global_position
	animation_player.play("attack_" + direction)
		
func _execute_attack():
	#execute attack during animation
	print_debug(target.global_position)

func _on_tracking_timer_timeout() -> void:
	follow_player()
