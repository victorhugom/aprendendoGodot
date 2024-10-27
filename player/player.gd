class_name  Player extends CharacterBody2D

const SCREEN_SHAKER = preload("res://utils/screen_shaker.tres")
const PROJECTILE = preload("res://player/projectile.tscn")
const PROJECTILE_BASIC_CONFIG = preload("res://player/projectile/basic_projectile.tres")
const MAGE_TRANSFORMATION_CONFIG = preload("res://player/player_transformation_litlemage.tres")

@export var groundMapTile: TileMapLayer
@export var speed = 32*5
@export var max_health = 3

@onready var follow_camera = $FollowCamera

#region Mage

@onready var shoot_timer: Timer = $ShootTimer
@export var mage_current_health: int
@export var mage_max_health: int

#endregion

@onready var punch_trace: ShapeCast2D = $PunchTrace

@onready var CharTransatormationsSprite = {
	Enums.TransformationsENUM.MAGE : $LittleMage,
	Enums.TransformationsENUM.SAUSAGE : $SausageMonster
}

@onready var CharTransatormationsAnimations = {
	Enums.TransformationsENUM.MAGE : $LittleMage/AnimationPlayer,
	Enums.TransformationsENUM.SAUSAGE : $SausageMonster/AnimationPlayer
}

@onready var CharTransatormationsCollisions = {
	Enums.TransformationsENUM.MAGE : $LittleMageMovementHitBox,
	Enums.TransformationsENUM.SAUSAGE : $SausageMovementHitBox
}

@onready var CharProjectilePosition = {
	Enums.TransformationsENUM.MAGE : $LittleMageProjectilePosition,
	Enums.TransformationsENUM.SAUSAGE : $LittleMageProjectilePosition
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

var current_transformation: Enums.TransformationsENUM = Enums.TransformationsENUM.MAGE
var last_transformation: Enums.TransformationsENUM = Enums.TransformationsENUM.MAGE
var current_transformation_config: PlayerTransformationConfig

func _ready() -> void:
	
	projectile_config = PROJECTILE_BASIC_CONFIG
	
	last_anim_direction = "down"
	is_transforming = false
	
	current_transformation_config = MAGE_TRANSFORMATION_CONFIG
	CharTransatormationsAnimations[Enums.TransformationsENUM.MAGE].play("idle_down")
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
			CharTransatormationsAnimations[current_transformation].play(animation_type + direction, -1, 2)
		else:
			CharTransatormationsAnimations[current_transformation].play(animation_type + direction)
	
func setCameraLimit():
	var map_limits = groundMapTile.get_used_rect()
	var map_cellsize = 32
	var worldMapInPixels = map_limits.size * map_cellsize
	
	follow_camera.limit_right = worldMapInPixels.x
	follow_camera.limit_bottom = worldMapInPixels.y
	
func attack() -> void:
	
	if is_atatcking: return
	is_atatcking = true
	
	CharTransatormationsAnimations[current_transformation].play("attack_" + last_anim_direction)
	
	if current_transformation == Enums.TransformationsENUM.MAGE:
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
		CharTransatormationsAnimations[current_transformation].play("block_" + last_anim_direction)

func transform(transformation_card = CardConfig) -> void:
	
	if is_transforming: 
		return
	
	is_transforming = true
	
	mage_max_health = max_health
	mage_current_health = health
	
	current_transformation_config = transformation_card.CardData.TransformationConfig
	
	speed = current_transformation_config.Speed
	health = current_transformation_config.MaxHealth
	max_health = current_transformation_config.MaxHealth
	
	Hud.health_bar.setMaxHearts(max_health)
	Hud.health_bar.updateHeats(health)
	
	last_transformation = Enums.TransformationsENUM.MAGE
	current_transformation = transformation_card.CardData.TransformationEnum

	#transform from last transformation to new
	CharTransatormationsAnimations[last_transformation].play("transform")
	last_anim_direction = "down"
	
func _complete_transformation():
	#after transform hide old char and show new
	
	#hide mage stuff
	CharTransatormationsSprite[last_transformation].visible = false
	CharTransatormationsCollisions[last_transformation].disabled = true
	
	#show transformation stuff
	CharTransatormationsSprite[current_transformation].visible = true
	CharTransatormationsCollisions[current_transformation].disabled = false
	
	is_transforming = false

	
func revert_transformation() -> void:
	
	current_transformation_config = MAGE_TRANSFORMATION_CONFIG
	
	speed = current_transformation_config.Speed
	max_health = mage_max_health
	health = mage_current_health
	
	Hud.health_bar.setMaxHearts(max_health)
	Hud.health_bar.updateHeats(health)
	
	last_transformation = current_transformation
	current_transformation = Enums.TransformationsENUM.MAGE

	#transform from last transformation to new
	CharTransatormationsAnimations[last_transformation].play("transform")
	last_anim_direction = "down"

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
		if current_transformation != Enums.TransformationsENUM.MAGE:
			revert_transformation()
		else:
			is_dying = true
			CharTransatormationsAnimations[current_transformation].play("death")
	else:
		is_being_hit = true
		#animation_player.play("hit")

func select_card(card_number:int):
	Hud.card_hand.select_card(card_number)
