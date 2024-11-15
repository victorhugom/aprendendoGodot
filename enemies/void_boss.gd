class_name VoidBoss extends CharacterBody2D

const VOID_TENTACLES = preload("res://enemies/voidTentacles.tscn")

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
	
	hurt_box.health = health
	hurt_box.damaged.connect(_on_damaged)
	hurt_box.can_be_hurt = true
	
	tracking_timer.connect("timeout", _on_tracking_timer_timeout)
	attack_timer.connect("timeout", _on_attack_timer_timeout)
	add_to_group("enemies")
	
func can_update_char() -> bool:
	
	if target == null:
		return false
		
	if global_position.distance_to(target.global_position) > 400:
		return false
		
	if is_dying || animation_player.current_animation.begins_with("attack") || animation_player.current_animation.begins_with("hit"): 
		return false
	
	if animation_player.current_animation.begins_with("super_attack"): 
		return false
		
	return true

func _physics_process(_delta: float) -> void:
	
	if target == null:
		target = Globals.player
	
	if can_update_char() == false:
		return	
	
	var angle = atan2(velocity.y, velocity.x) # angle in [-PI, PI]
	if velocity.length() > 0:
		if abs(angle) < 0.25 * PI:
			direction = "right"
		elif abs(angle) > 0.75 * PI:
			direction = "left"
			
	if global_position.distance_to(target.global_position) > 24 || animation_player.current_animation.begins_with("spin_attack"):
		#too far from player, keep walking
		var next_path_position = navigation_agent_2d.get_next_path_position()
		var current_position = global_position
		velocity = current_position.direction_to(next_path_position) * speed
		move_and_slide()
	else:
		#close enough to attack
		_on_attack_timer_timeout() #run first attack as soon is close
		velocity = Vector2(0,0)
		
	var animation_type = "walk_"
	if velocity.length() <= 0:
		animation_type = "idle_"

	if not animation_player.current_animation.begins_with("spin_attack"):
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

func create_void_tectacles():
	
	var radius = 400
	var angle = randf_range(0, PI * 2)
	var distance = randf_range(0, radius)
	var offset = Vector2(cos(angle), sin(angle)) * distance
	var tentacle_position =  global_position + offset
	
	var new_void_tentacles = VOID_TENTACLES.instantiate()
	new_void_tentacles.global_position = tentacle_position
	get_tree().root.add_child(new_void_tentacles)

func super_attack():
	pass

func update_target():
	target = Globals.player

func _on_damaged() -> void:
	if is_dying: return
	animation_player.play("hit_" + direction)

func _on_health_empty():
	is_dying = true
	
	attack_timer.stop()
	animation_player.play("death")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		queue_free()

func _on_attack_timer_timeout() -> void:
	
	if is_dying: 
		return
	
	if animation_player.current_animation.contains("attack"):
		return
	
	var attack_dice = randi_range(1, 10)
	
	if attack_dice >= 1 and attack_dice <= 2: #has 20% of change to run the spin attack
		animation_player.play("spin_attack")
	elif attack_dice == 3:
		animation_player.play("super_attack")
	elif global_position.distance_to(target.global_position) <= 24:
		target_position = target.global_position
		animation_player.play("attack_" + direction)
		
func _on_tracking_timer_timeout() -> void:
	if target != null:
		follow_player()
