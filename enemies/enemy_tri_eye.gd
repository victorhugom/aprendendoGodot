class_name EnemyTriEye extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var tracking_timer: Timer = $NavigationAgent2D/TrackingTimer
@onready var hurt_box: HurtBox = $HurtBox
@onready var hit_box: CollisionShape2D = $HitBox
@onready var health: Health = $Health
@onready var health_bar: HBoxContainer = $HealthBar
@onready var navigation_agent_2d: NavigationAgent2D = $NavigationAgent2D

@export var target: Node
@export var speed: int
## Minimum distance where the enemy starts to track the player (in pixels), ie: only tracks the player if they are less than 200px far
@export var tracking_distance:= 250

var is_dying = false
var direction = "left"
var target_position: Vector2

func _ready() -> void:
	
	#health setup
	health.health_empty.connect(_on_health_empty)
	health_bar.health = health
	hurt_box.health = health
	hurt_box.damaged.connect(_on_damaged)
	hurt_box.can_be_hurt = true
	
	tracking_timer.connect("timeout", _on_tracking_timer_timeout)
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
	
	var animation_type = "walk_"
	
	var next_path_position = navigation_agent_2d.get_next_path_position()
	velocity = global_position.direction_to(next_path_position) * speed
	
	var angle = atan2(velocity.y, velocity.x) # angle in [-PI, PI]
	if abs(angle) < 0.25 * PI:
		direction = "right"
	else:
		direction = "left"
	
	if global_position.distance_to(target.global_position) <= 24:
		attack() #run first attack as soon is close
	else:
		#too far from player, keep walking
		move_and_slide()
		if velocity.length() > 0:
			animation_type = "walk_"
		else: #walking
			animation_type = "idle_"
			
		move_and_slide()
		animation_player.play(animation_type +  direction)
		
func follow_player() -> void:
	
	var direction_to_player = target.global_position - global_position 
	var horizontal_target_pos = global_position 
	var side_offset = 24 # Distance to the left or right of the player
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
	animation_player.play("hit_" + direction)

func _on_health_empty():
	
	is_dying = true
	hurt_box.set_deferred("monitoring", false)
	hurt_box.set_deferred("monitorable", false)
	
	hit_box.set_deferred("disabled", true)
	
	animation_player.play("death")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()

func attack() -> void:
	
	if is_dying: 
		return
	
	if global_position.distance_to(target.global_position) > 24:
		return
		
	if animation_player.current_animation.begins_with("attack"):
		return
		
	velocity = global_position.direction_to(target.global_position) * speed
	var angle = atan2(velocity.y, velocity.x) # angle in [-PI, PI]
	if abs(angle) < 0.25 * PI:
		direction = "right"
	else:
		direction = "left"
	
	target_position = target.global_position
	animation_player.play("attack_" + direction)
		
func _on_tracking_timer_timeout() -> void:
	if target != null:
		follow_player()
