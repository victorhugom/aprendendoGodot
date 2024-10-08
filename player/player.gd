extends CharacterBody2D

@export var speed = 16*5
@export var groundMapTile: TileMapLayer

@onready var animations = $AnimationPlayer
@onready var walk_sprite = $WalkSprite
@onready var idle_sprite = $IdleSprite
@onready var follow_camera = $FollowCamera

var last_anim_direction = "down"

func _ready() -> void:
	animations.play("RESET")
	setCameraLimit()
	walk_sprite.visible = false
	idle_sprite.visible = true

func _physics_process(delta: float) -> void:
	handleInput()
	move_and_slide()
	updateAnimation()

func handleInput():
	var move_direction = Input.get_vector( "ui_left", "ui_right", "ui_up","ui_down")
	velocity = move_direction * speed
	
func updateAnimation():
	var direction = last_anim_direction
	var animation_type = "walk_"
	
	if velocity.length() == 0: #idle
		walk_sprite.visible = false
		idle_sprite.visible = true
		animation_type = "idle_"
	else: #walking
		walk_sprite.visible = true
		idle_sprite.visible = false
		animation_type = "walk_"
		
		if velocity.x < 0: direction = "left"
		elif velocity.x > 0: direction = "right"
		elif velocity.y < 0: direction = "up"
		elif velocity.y > 0: direction = "down"
		
	last_anim_direction = direction
	animations.play(animation_type + direction)

	
func setCameraLimit():
	var map_limits = groundMapTile.get_used_rect()
	var map_cellsize = 16
	var worldMapInPixels = map_limits.size * map_cellsize
	
	follow_camera.limit_right = worldMapInPixels.x
	follow_camera.limit_bottom = worldMapInPixels.y
