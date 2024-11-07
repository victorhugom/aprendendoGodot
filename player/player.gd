class_name Player extends CharacterBody2D

const PROJECTILE_BASIC_CONFIG = preload("res://player/projectile/playerProjectile/basic_projectile.tres")
const DECK_BUILDER = preload("res://player/cards/deckBuilder.tscn")
const CARD_HAND = preload("res://player/character_components/cardHand.tscn")
const SAUSAGE_MONSTER = preload("res://player/sausage_monster.tscn")
const DEATH_SCREEN = preload("res://gui/deathScreen.tscn")

@onready var health: Health = $Health
@onready var hurt_box: HurtBox  = $HurtBox
@onready var shooter: Shooter = $Shooter
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_take_hit: AnimationPlayer = $AnimationPlayerTakeHit
@onready var follow_camera: FollowCamera = $FollowCamera

@export var ground_map_tile: TileMapLayer
@export var max_health = 9

@export var speed = 32 * 5
@export var dash_speed = 32 * 10
@export var walk_speed = 32 * 5
@export var dash_duration = 0.35
@export var dash_cooldown = 1

var transformation: Node2D
var is_dying = false
var is_being_hit = false

#region Deck Builder
var deck_builder: DeckBuilder
var card_hand: CardHand
var card_deck: Array[CardConfig]
#endregion

var projectile_config: ProjectileConfig

var is_atatcking = false
var is_transforming = false
var last_anim_direction = "down"
var move_direction_vector = Vector2(0,0)

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown_timer = 0.0

func _ready() -> void:
	
	shooter.projectile_config = PROJECTILE_BASIC_CONFIG
	
	last_anim_direction = "down"
	animation_player.play("idle_down")
	
	is_transforming = false
	
	#camera setup
	follow_camera.ground_map_tile = ground_map_tile
	follow_camera.set_camera_limit()
	
	#health setup
	health.health_empty.connect(_on_health_empty)
	health.max_health = max_health
	health.current_health = max_health
	Hud.health_bar.health = health
	hurt_box.damaged.connect(_on_hit)
	
	#deck builder setup
	deck_builder = DECK_BUILDER.instantiate()
	deck_builder.closed.connect(_on_deck_builder_closed)
	deck_builder.opened.connect(_on_deck_builder_opened)
	add_child(deck_builder)
	
	Globals.player = self
	get_tree().call_group("enemies", "update_target")

func _physics_process(_delta: float) -> void:

	hurt_box.can_be_hurt = can_take_damage()
	
	if is_dying || is_being_hit: return
	
	handle_movement_input()
	update_animation()
	
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= _delta
	
	if is_dashing:
		speed = dash_speed
		dash_timer -= _delta
		if dash_timer <= 0:
			is_dashing = false
			speed = walk_speed
	
	if is_atatcking == false && is_transforming == false:
		move_and_slide()

func _input(event):
	
	if is_dying: return
	
	if event.is_action_pressed("ui_attack"):
		prepare_attack()
	if event.is_action_pressed("ui_dash"):
		dash()
	if event.is_action_pressed("ui_draw_cards"):
		if card_hand.draw_cards():
			health.decrease_health(1)
			_on_hit()
	
	for i in range(KEY_0, KEY_9):  # Loop from KEY_0 to KEY_9
		if event is InputEventKey && event.keycode == i && event.is_released():
			select_card(OS.get_keycode_string(i).to_int())

func handle_movement_input():
	move_direction_vector = Input.get_vector( "ui_left", "ui_right", "ui_up","ui_down")
	velocity = move_direction_vector * speed

func update_animation():
	
	var direction = last_anim_direction
	var animation_type = "walk_"
	
	if velocity.length() > 0: #idle
		if is_dashing:
			animation_type = "dash_"
		
		var angle = atan2(velocity.y, velocity.x) # angle in [-PI, PI]
		if abs(angle) < 0.25 * PI:
			direction = "right"
		elif abs(angle) > 0.75 * PI:
			direction = "left"
		elif angle > 0.0:
			direction = "down"
		else:
			direction = "up"

	else: #walking
		animation_type = "idle_"
		
	last_anim_direction = direction
	if is_atatcking == false && is_transforming == false:
		if animation_type == "dash_":
			animation_player.play(animation_type + direction, -1, 2)
		else:
			animation_player.play(animation_type + direction)
	

func prepare_attack() -> void:
	
	if is_atatcking: return
	is_atatcking = true
	
	animation_player.play("attack_" + last_anim_direction)

func attack() -> void:
	
	card_hand.use_selected_card()

	shooter.projectile_config = projectile_config
	shooter.shoot(last_anim_direction, (card_hand.card_selected.card_config.CardData as CardDataProjectile).DPS)
	
func dash():

	is_dashing = true
	dash_timer = dash_duration
	dash_cooldown_timer = dash_cooldown

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack_"):
		is_atatcking = false
	if anim_name.begins_with("hit"):
		is_being_hit = false
	if anim_name.begins_with("transform"):
		is_transforming = false
		get_tree().root.	add_child(transformation)
	if anim_name.begins_with("death"):
		var death_screen = DEATH_SCREEN.instantiate()
		get_tree().root.add_child(death_screen)

func _on_hit():
	if is_dying: return
	is_being_hit = true
	animation_player_take_hit.play("hit_" + last_anim_direction)
	
func _on_health_empty():
	is_dying = true
	animation_player.play("death")
		
func recover_life(value: int) -> void:
	health.increase_health(value)

func select_card(card_number:int):
	print_debug("select card")
	card_hand.select_card(card_number)
	
func can_take_damage():
	return is_dying == false && health.current_health > 0
	
func _on_deck_builder_opened() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func _on_deck_builder_closed(deck: Array[CardInDeck]) -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	remove_child(deck_builder)
	deck_builder.queue_free()
	
	for card:CardInDeck in deck:
		card.get_parent().remove_child(card)
	
	create_deck_hand(deck)
	
func create_deck_hand(deck: Array[CardInDeck]):
	card_hand = CARD_HAND.instantiate()
	card_hand.card_deck = deck
	card_hand.card_selected_changed.connect(_on_card_selected_changed)
	
	add_child(card_hand)
	card_hand.draw_cards(2)
	
func _on_card_selected_changed(card_selected: Card):
	
	if card_selected.card_config.CardType == Enums.CARD_TYPE.Projectile:
		projectile_config = (card_selected.card_config.CardData as CardDataProjectile).projectile_config
	if card_selected.card_config.CardType == Enums.CARD_TYPE.Transform:
		card_hand.use_selected_card()
		transform(card_selected.card_config)
	if card_selected.card_config.CardType == Enums.CARD_TYPE.Life:
		var health_card_data = card_selected.card_config.CardData as CardDataHealth
		var result: bool = health.increase_health(health_card_data.health)
		if result:
			card_hand.use_selected_card()
		else:
			card_hand.select_previous_card()
	
func transform(_transformation_card = CardConfig) -> void:
	
	if is_transforming: 
		return
	
	is_transforming = true
	Globals.player = self
	
	transformation = SAUSAGE_MONSTER.instantiate()
	transformation.position = global_position
	transformation.ground_map_tile = ground_map_tile

	#transform from last transformation to new
	animation_player.play("transform")
	last_anim_direction = "down"
