class_name  Player extends CharacterBody2D

enum TransformationsENUM {
	MAGE,
	SAUSAGE
}

const PROJECTILE = preload("res://player/projectile.tscn")

@export var groundMapTile: TileMapLayer
@export var speed = 32*5

@onready var follow_camera = $FollowCamera

@onready var CharTransatormations = {
	TransformationsENUM.MAGE : $LittleMage,
	TransformationsENUM.SAUSAGE : $SausageMonster
}

@onready var CharTransatormationsAnimations = {
	TransformationsENUM.MAGE : $LittleMage/AnimationPlayer,
	TransformationsENUM.SAUSAGE : $SausageMonster/AnimationPlayer
}

@onready var CharTransatormationsCollisions = {
	TransformationsENUM.MAGE : $LittleMageMovementCollision,
	TransformationsENUM.SAUSAGE : $SausageMovementCollision
}

@onready var CharTransformationsConfig: = {
	TransformationsENUM.MAGE : preload("res://player/player_transformation_litlemage.tres"),
	TransformationsENUM.SAUSAGE : preload("res://player/player_transformation_sausage.tres")
}

@onready var CharProjectilePosition = {
	TransformationsENUM.MAGE : $LittleMageProjectilePosition,
	TransformationsENUM.SAUSAGE : $LittleMageProjectilePosition
}


var last_anim_direction = "down"
var move_direction_vector = Vector2(0,0)
var is_blocking = false
var is_atatcking = false
var is_transforming = false

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0

var animations: AnimationPlayer = null
var current_transformation: TransformationsENUM = TransformationsENUM.MAGE
var last_transformation: TransformationsENUM = TransformationsENUM.SAUSAGE
var current_transformation_config: PlayerTransformationConfig

func _ready() -> void:
	
	transform(TransformationsENUM.MAGE)
	is_transforming = false
	
	animations.play("idle_down")
	setCameraLimit()

func _physics_process(_delta: float) -> void:
	handleInput()
	update_animation()
	
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
	if event.is_action_pressed("ui_dash"):
		dash()
		
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
		var projectile = PROJECTILE.instantiate()
		projectile.position = CharProjectilePosition[current_transformation].global_position
		projectile.set_config(preload("res://player/projectile/basic_projectile.tres"))
		
		get_parent().add_sibling(projectile)
		projectile.shoot(last_anim_direction)
	
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
	if anim_name.begins_with("block_"):
		is_blocking = false
	if anim_name.begins_with("transform"):
		_complete_transformation()
	
		
