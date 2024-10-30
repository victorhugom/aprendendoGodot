class_name SausageMonster extends CharacterBody2D

const SCREEN_SHAKER = preload("res://utils/screen_shaker.tres")

const PROJECTILE = preload("res://player/projectile.tscn")
const PROJECTILE_BASIC_CONFIG = preload("res://player/projectile/playerProjectile/basic_projectile.tres")

@onready var health: Health = $Health
@onready var hurt_box: HurtBox  = $HurtBox

@export var groundMapTile: TileMapLayer
@export var max_health = 3

@export_group("Movement")
@export var speed = 32 * 5
@export var walk_speed = 32 * 5

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var projectile_position = $ProjectilePosition
@onready var shoot_timer: Timer = $ShootTimer
@onready var follow_camera: FollowCamera = $FollowCamera


var is_dying = false
var is_being_hit = false

var projectile_config: ProjectileConfig
var dps = 1

var is_blocking = false
var is_atatcking = false
var is_tracing_punch = false
var is_transforming = false
var last_anim_direction = "down"
var move_direction_vector = Vector2(0,0)

func _ready() -> void:
	
	projectile_config = PROJECTILE_BASIC_CONFIG
	
	last_anim_direction = "down"
	animation_player.play("idle_down")
	
	is_transforming = false
	
	#camera setup
	follow_camera.groundMapTile = groundMapTile
	follow_camera.set_camera_limit()
	
	#health setup
	health.health_empty.connect(_on_health_empty)
	hurt_box.damaged.connect(_on_hit)
	Hud.health_bar.health = health
	

func _physics_process(_delta: float) -> void:

	hurt_box.can_be_hurt = can_take_damage()
	
	if is_dying || is_being_hit: return
	
	handle_movement_input()
	
	if is_atatcking == false && is_blocking == false && is_transforming == false:
		update_animation()
		move_and_slide()

func _input(event):
	if is_dying: return
	
	if event.is_action_pressed("ui_attack"):
		attack()

func handle_movement_input():
	move_direction_vector = Input.get_vector( "ui_left", "ui_right", "ui_up","ui_down")
	velocity = move_direction_vector * speed

func update_animation():
	
	var direction = last_anim_direction
	var animation_type = "walk_"
	
	if velocity.length() == 0: #idle
		animation_type = "idle_"
	else: #walking
		animation_type = "walk_"
		
	if velocity.x < 0: direction = "left"
	elif velocity.x > 0: direction = "right"
	elif velocity.y < 0: direction = "up"
	elif velocity.y > 0: direction = "down"
		
	last_anim_direction = direction
	animation_player.play(animation_type + direction)
	
func attack() -> void:
	
	if is_atatcking: return
	is_atatcking = true
	
	animation_player.play("attack_" + last_anim_direction)

	#for i in range(0, dps):
		#var projectile = PROJECTILE.instantiate()
		#projectile.position = projectile_position.global_position
		#projectile.set_config(projectile_config)
		#
		#if last_anim_direction == "left":
			#projectile.position.x -= 30
		#if last_anim_direction == "right":
			#projectile.position.x += 30
		#if last_anim_direction == "up":
			#projectile.position.y -= 30
		#if last_anim_direction == "down":
			#projectile.position.y += 30
		#
		#get_parent().add_sibling(projectile)
		#projectile.shoot(last_anim_direction)
		#
		#shoot_timer.start()
		#await shoot_timer.timeout
		
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack_"):
		is_atatcking = false
	if anim_name.begins_with("hit"):
		is_being_hit = false
	if anim_name.begins_with("transform"):
		is_transforming = false
	if anim_name.begins_with("block_"):
		is_blocking = false

func _on_hit():
	is_being_hit = true
	animation_player.play("hit")
	
func _on_health_empty():
	is_dying = true
	animation_player.play("death")
		
func can_take_damage():
	return is_dying == false || health.current_health > 0 || is_blocking == false

func block() -> void:
	is_blocking = true
	animation_player.play("block_" + last_anim_direction)	
	

func shake():
	Shaker.shake_by_preset(SCREEN_SHAKER, follow_camera, 2, 5, 20)
