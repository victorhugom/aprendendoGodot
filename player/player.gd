class_name  Player extends CharacterBody2D

enum TransformationsENUM {
	MAGE,
	SAUSAGE
}

const SCREEN_SHAKER = preload("res://utils/screen_shaker.tres")
const PROJECTILE = preload("res://player/projectile.tscn")
const PROJECTILE_BASIC_CONFIG = preload("res://player/projectile/basic_projectile.tres")

@export var groundMapTile: TileMapLayer
@export var speed = 32*5
@export var max_health = 3

@onready var follow_camera = $FollowCamera
@onready var punch_trace: ShapeCast2D = $PunchTrace
@onready var shoot_timer: Timer = $ShootTimer

@onready var CharTransatormations = {
	TransformationsENUM.MAGE : $LittleMage,
	TransformationsENUM.SAUSAGE : $SausageMonster
}

@onready var CharTransatormationsAnimations = {
	TransformationsENUM.MAGE : $LittleMage/AnimationPlayer,
	TransformationsENUM.SAUSAGE : $SausageMonster/AnimationPlayer
}

@onready var CharTransatormationsCollisions = {
	TransformationsENUM.MAGE : $LittleMageMovementHitBox,
	TransformationsENUM.SAUSAGE : $SausageMovementHitBox
}

@onready var CharTransformationsConfig: = {
	TransformationsENUM.MAGE : preload("res://player/player_transformation_litlemage.tres"),
	TransformationsENUM.SAUSAGE : preload("res://player/player_transformation_sausage.tres")
}

@onready var CharProjectilePosition = {
	TransformationsENUM.MAGE : $LittleMageProjectilePosition,
	TransformationsENUM.SAUSAGE : $LittleMageProjectilePosition
}

var health = max_health
var is_dying = false
var is_being_hit = false

var card_hand: CardHand
var card_deck: Array[CardConfig]
var card_selected: Card
var previous_key_pressed: int

@export var projectile_config: ProjectileConfig
@export var dps = 1

var last_anim_direction = "down"
var move_direction_vector = Vector2(0,0)
var is_blocking = false
var is_atatcking = false
var is_tracing_punch = false
var is_transforming = false

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0

var animations: AnimationPlayer = null
var current_transformation: TransformationsENUM = TransformationsENUM.MAGE
var last_transformation: TransformationsENUM = TransformationsENUM.SAUSAGE
var current_transformation_config: PlayerTransformationConfig

func _ready() -> void:
	
	projectile_config = PROJECTILE_BASIC_CONFIG
	
	transform(TransformationsENUM.MAGE)
	is_transforming = false
	
	animations.play("idle_down")
	setCameraLimit()
	
	Hud.card_hand.player = self
	Hud.card_hand.draw_cards()
	Hud.health_bar.setMaxHearts(max_health)
	Hud.health_bar.updateHeats(health)

func _physics_process(_delta: float) -> void:
	
	if is_dying: return
	
	handleInput()
	update_animation()
	trace_punch()
	
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= _delta
	
	if is_dashing:
		speed = current_transformation_config.DashSpeed
		dash_timer -= _delta
		if dash_timer <= 0:
			is_dashing = false
			speed = current_transformation_config.Speed
	
	if is_atatcking == false && is_blocking == false && is_transforming == false:
		move_and_slide()

func handleInput():
	move_direction_vector = Input.get_vector( "ui_left", "ui_right", "ui_up","ui_down")
	velocity = move_direction_vector * speed

func _input(event):
	if event.is_action_pressed("ui_attack"):
		attack()
	if event.is_action_pressed("ui_block"):
		block()
	if event.is_action_released("ui_block"):
		is_blocking = false
	if event.is_action_pressed("ui_dash"):
		dash()
		
	for i in range(KEY_0, KEY_9):  # Loop from KEY_0 to KEY_9
		if previous_key_pressed == i: continue
		if Input.is_key_pressed(i):
			previous_key_pressed = i
			select_card(OS.get_keycode_string(i).to_int())
			
	# FOR TEST PURPOSE
	if event.is_action_pressed("ui_test"):
		if current_transformation == TransformationsENUM.MAGE:
			transform(TransformationsENUM.SAUSAGE)
			return
		if current_transformation == TransformationsENUM.SAUSAGE:
			transform(TransformationsENUM.MAGE)
			return
	
func update_animation():
	
	var direction = last_anim_direction
	var animation_type = "walk_"
	
	if velocity.length() == 0: #idle
		animation_type = "idle_"
	else: #walking
		animation_type = "walk_"
	
	if is_dashing:
		animation_type = "dash_"
		
	if velocity.x < 0: direction = "left"
	elif velocity.x > 0: direction = "right"
	elif velocity.y < 0: direction = "up"
	elif velocity.y > 0: direction = "down"
		
	last_anim_direction = direction
	if is_atatcking == false && is_blocking == false && is_transforming == false:
		if animation_type == "dash_":
			animations.play(animation_type + direction, -1, 2)
		else:
			animations.play(animation_type + direction)
	
func setCameraLimit():
	var map_limits = groundMapTile.get_used_rect()
	var map_cellsize = 32
	var worldMapInPixels = map_limits.size * map_cellsize
	
	follow_camera.limit_right = worldMapInPixels.x
	follow_camera.limit_bottom = worldMapInPixels.y
	
func attack() -> void:
	
	if is_atatcking: return
	is_atatcking = true
	
	animations.play("attack_" + last_anim_direction)
	
	if current_transformation == TransformationsENUM.MAGE:
		Hud.card_hand.use_selected_card()
		for i in range(0, dps):
			var projectile = PROJECTILE.instantiate()
			projectile.position = CharProjectilePosition[current_transformation].global_position
			
			if last_anim_direction == "left":
				projectile.position.x -= 30
			if last_anim_direction == "right":
				projectile.position.x += 30
			if last_anim_direction == "up":
				projectile.position.y -= 30
			if last_anim_direction == "down":
				projectile.position.y += 30
			
			projectile.set_config(projectile_config)
			
			get_parent().add_sibling(projectile)
			projectile.shoot(last_anim_direction)
			
			shoot_timer.start()
			await shoot_timer.timeout
	
func block() -> void:
	if current_transformation_config.CanBlock:
		is_blocking = true
		animations.play("block_" + last_anim_direction)

func transform(transformation = TransformationsENUM.MAGE) -> void:
	
	if is_transforming: return
	is_transforming = true
	
	if animations:
		animations.play("transform")
	else:
		_complete_transformation()
		
	last_transformation = current_transformation
	current_transformation = transformation

func _complete_transformation():
	
	CharTransatormations[last_transformation].visible = false
	CharTransatormationsCollisions[last_transformation].disabled = true
	
	CharTransatormations[current_transformation].visible = true
	CharTransatormationsCollisions[current_transformation].disabled = false
	
	current_transformation_config = CharTransformationsConfig[current_transformation]
	animations = CharTransatormationsAnimations[current_transformation]
	speed = current_transformation_config.Speed
	last_anim_direction = "down"
	
	is_transforming = false

func dash():
	if current_transformation_config.DashSpeed > 0:
		is_dashing = true
		dash_timer = current_transformation_config.DashDuration
		dash_cooldown_timer = current_transformation_config.DashCooldown

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack_"):
		is_atatcking = false
	if anim_name.begins_with("transform"):
		_complete_transformation()

func start_punch_trace():
	is_tracing_punch = true
	
func end_punch_trace():
	is_tracing_punch = false

func shake():
	Shaker.shake_by_preset(SCREEN_SHAKER, follow_camera, 2, 5, 20)
	
func trace_punch():
	
	if is_tracing_punch == false: return
	
	if last_anim_direction == "left":
		punch_trace.target_position = Vector2(0,-100)
	else:
		punch_trace.target_position = Vector2(0,100)

	if punch_trace.is_colliding():
		
		for i in range(0, punch_trace.get_collision_count()):
			var hurtbox = punch_trace.get_collider(i)
			var body = hurtbox.get_parent()
			if body is Enemy:
				(body as Enemy).damage(3, Enums.ELEMENTS.SUPER, velocity)
				
		is_tracing_punch = false
		
func damage(hurt_points: int, damage_type: Enums.ELEMENTS) -> void:
	
	if is_blocking: return
	
	if is_dying: return
	
	health -= hurt_points
	Hud.health_bar.updateHeats(health)
	
	if health <= 0:
		is_dying = true
		animations.play("death")
	else:
		is_being_hit = true
		#animation_player.play("hit")
		
func select_card(card_number:int):
	Hud.card_hand.select_card(card_number)
