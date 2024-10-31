class_name SausageMonster extends CharacterBody2D

const SCREEN_SHAKER = preload("res://utils/screen_shaker.tres")

const PROJECTILE = preload("res://player/projectile.tscn")
const PROJECTILE_BASIC_CONFIG = preload("res://player/projectile/playerProjectile/basic_projectile.tres")

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_blink: AnimationPlayer = $AnimationPlayerBlink
@onready var follow_camera: FollowCamera = $FollowCamera
@onready var health: Health = $Health
@onready var hurt_box: HurtBox  = $HurtBox
@onready var shooter: Shooter = $Shooter
@onready var punch_collision_area: MeleeCollisionBox = $PunchCollisionArea


@export var ground_map_tile: TileMapLayer
@export var max_health = 3

@export_group("Movement")
@export var speed = 32 * 5
@export var walk_speed = 32 * 5


var projectile_config: ProjectileConfig
var dps = 1

var is_being_hit = false
var is_blocking = false
var is_atatcking = false
var is_transforming = false
var last_anim_direction = "down"

var move_direction_vector = Vector2(0,0)
var previous_char: Node

func _ready() -> void:
	
	shooter.projectile_config = PROJECTILE_BASIC_CONFIG
	
	last_anim_direction = "down"
	animation_player.play("idle_down")
	
	#camera setup
	follow_camera.ground_map_tile = ground_map_tile
	follow_camera.set_camera_limit()
	
	#health setup
	health.health_empty.connect(_on_health_empty)
	hurt_box.damaged.connect(_on_hit)
	Hud.health_bar.health = health
	
	previous_char = Globals.player
	Globals.player =  self
	previous_char.get_parent().remove_child(previous_char)
	get_tree().call_group("enemies", "update_target")
	
	punch_collision_area.monitorable = false
	punch_collision_area.monitoring = false
	
func _physics_process(_delta: float) -> void:

	hurt_box.can_be_hurt = can_take_damage()
	
	if is_transforming || is_being_hit: return
	
	handle_movement_input()
	
	if is_atatcking == false && is_blocking == false && is_transforming == false:
		update_animation()
		move_and_slide()

func _input(event):
	if is_transforming: return
	
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
		
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack_"):
		is_atatcking = false
	if anim_name.begins_with("hit"):
		is_being_hit = false
	if anim_name.begins_with("transform"):
		is_transforming = false
		
		var current_position = global_position
		get_tree().root.add_child(previous_char)
		get_tree().call_group("enemies", "update_target")
		previous_char.global_position = current_position
		Hud.health_bar.health = previous_char
		self.get_parent().remove_child(self)
		
	if anim_name.begins_with("block_"):
		is_blocking = false

func _on_hit():
	if is_transforming: return
	
	is_being_hit = true
	animation_player_blink.play("hit_" + last_anim_direction)
	
func _on_finish_hit_blink():
	is_being_hit = false
	
func _on_health_empty():
	is_transforming = true
	animation_player.play("transform")
		
func can_take_damage():
	return is_transforming == false && health.current_health > 0 && is_blocking == false

func block() -> void:
	is_blocking = true
	animation_player.play("block_" + last_anim_direction)	

func shake():
	Shaker.shake_by_preset(SCREEN_SHAKER, follow_camera, 2, 5, 20)
