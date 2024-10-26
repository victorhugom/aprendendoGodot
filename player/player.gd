class_name  Player extends CharacterBody2D

enum TransformationsENUM {
	MAGE,
	SAUSAGE
}

@export var speed = 32*5
@export var groundMapTile: TileMapLayer

@onready var animations_litle_mage = $LitleMage/AnimationPlayerLitleMage
@onready var animations_sausage_monster = $SausageMonster/AnimationPlayerSausageMonster
@onready var follow_camera = $FollowCamera

@onready var CharTransatormations = {
	TransformationsENUM.MAGE : $LitleMage,
	TransformationsENUM.SAUSAGE : $SausageMonster
}

@onready var CharTransatormationsAnimations = {
	TransformationsENUM.MAGE : $LitleMage/AnimationPlayerLitleMage,
	TransformationsENUM.SAUSAGE : $SausageMonster/AnimationPlayerSausageMonster
}

@onready var CharTransatormationsCollisions = {
	TransformationsENUM.MAGE : $LitleMageMovementCollision,
	TransformationsENUM.SAUSAGE : $SausageMovementCollision
}

var last_anim_direction = "down"
var is_atatcking = false
var is_blocking = false
var animations: AnimationPlayer = null
var current_transformation: TransformationsENUM = TransformationsENUM.MAGE

func _ready() -> void:
	
	transform(TransformationsENUM.MAGE)
	
	animations.play("idle_down")
	setCameraLimit()

func _physics_process(_delta: float) -> void:
	handleInput()
	updateAnimation()
	if is_atatcking == false && is_blocking == false:
		move_and_slide()

func handleInput():
	var move_direction = Input.get_vector( "ui_left", "ui_right", "ui_up","ui_down")
	velocity = move_direction * speed

func _input(event):
	if event.is_action_pressed("ui_attack"):
		attack()
	if event.is_action_pressed("ui_block"):
		block()
		
	# FOR TEST PURPOSE
	if event.is_action_pressed("ui_test"):
		if current_transformation == TransformationsENUM.MAGE:
			transform(TransformationsENUM.SAUSAGE)
			return
		if current_transformation == TransformationsENUM.SAUSAGE:
			transform(TransformationsENUM.MAGE)
			return
	
func updateAnimation():
	
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
	if is_atatcking == false && is_blocking == false:
		animations.play(animation_type + direction)
	
func setCameraLimit():
	var map_limits = groundMapTile.get_used_rect()
	var map_cellsize = 32
	var worldMapInPixels = map_limits.size * map_cellsize
	
	follow_camera.limit_right = worldMapInPixels.x
	follow_camera.limit_bottom = worldMapInPixels.y
	
func attack() -> void:
	# quando tiver animação de ataque:
	# 1: remove o comentário das linhas abaixo (hashtag/jogo da velha)
	# 2: remove o "pass"
	# 3: remove o loop da animação
	# PS: a animação deve ter o nome attack_DIRECÃO_DO_ATAQUE ex: attack_left
	
	#is_atatcking = true
	#animations.play("attack_" + last_anim_direction)
	pass
	
func block() -> void:
	is_blocking = true
	animations.play("block_" + last_anim_direction)

func transform(transformation = TransformationsENUM.MAGE) -> void:
	
	current_transformation = transformation
	
	for key in CharTransatormations.keys():
		CharTransatormations[key].visible = false
		CharTransatormationsCollisions[key].disabled = true
	
	var char_transformation: Sprite2D = CharTransatormations[transformation]
	var char_transformation_collision: CollisionShape2D = CharTransatormationsCollisions[transformation]
	char_transformation.visible = true
	char_transformation_collision.disabled = false
	
	animations = CharTransatormationsAnimations[transformation]

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack_"):
		is_atatcking = false
	if anim_name.begins_with("block_"):
		is_blocking = false
