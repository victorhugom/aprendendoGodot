extends CharacterBody2D

@export var speed = 16*5
@export var groundMapTile: TileMapLayer

@onready var animations = $AnimationPlayer
@onready var walkSprite = $WalkSprite
@onready var idleSprite = $IdleSprite
@onready var followCamera = $FollowCamera

var lastAnimDirection = "down"

func _ready() -> void:
	animations.play("RESET")
	setCameraLimit()
	walkSprite.visible = false
	idleSprite.visible = true

func _physics_process(delta: float) -> void:
	handleInput()
	move_and_slide()
	updateAnimation()

func handleInput():
	var moveDirection = Input.get_vector( "ui_left", "ui_right", "ui_up","ui_down")
	velocity = moveDirection * speed
	
func updateAnimation():
	var direction = lastAnimDirection
	var animation_type = "walk_"
	
	if velocity.length() == 0: #idle
		walkSprite.visible = false
		idleSprite.visible = true
		animation_type = "idle_"
	else: #walking
		walkSprite.visible = true
		idleSprite.visible = false
		animation_type = "walk_"
		
		if velocity.x < 0: direction = "left"
		elif velocity.x > 0: direction = "right"
		elif velocity.y < 0: direction = "up"
		elif velocity.y > 0: direction = "down"
		
	lastAnimDirection = direction
	animations.play(animation_type + direction)

	
func setCameraLimit():
	var map_limits = groundMapTile.get_used_rect()
	var map_cellsize = 16
	var worldMapInPixels = map_limits.size * map_cellsize
	
	followCamera.limit_right = worldMapInPixels.x
	followCamera.limit_bottom = worldMapInPixels.y
