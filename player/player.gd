class_name Player extends CharacterBody2D

const PROJECTILE_BASIC_CONFIG = preload("res://player/projectile/playerProjectile/basic_projectile.tres")
const DECK_BUILDER = preload("res://cards/deckBuilder.tscn")
const CARD_HAND = preload("res://player/character_components/cardHand.tscn")
const SAUSAGE_MONSTER = preload("res://player/sausage_monster.tscn")
const DEATH_SCREEN = preload("res://gui/deathScreen.tscn")

@onready var health: Health = $Health
@onready var hurt_box: HurtBox  = $HurtBox
@onready var shooter: Shooter = $Shooter
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_player_take_hit: AnimationPlayer = $AnimationPlayerTakeHit
@onready var follow_camera: FollowCamera = $FollowCamera
@onready var inventory: Inventory = $Inventory

@export var ground_map_tile: TileMapLayer

@export var speed = 32 * 5
@export var dash_speed = 32 * 10
@export var walk_speed = 32 * 5
@export var dash_duration = 0.35
@export var dash_cooldown = 1

#region Deck Builder
var deck_builder: DeckBuilder
var card_hand: CardHand
var deck_cards: Array[DeckCardItem] #full deck
#endregion

var saved_game = SavedGame

var transformation: Node2D

var is_dying = false
var is_dashing = false
var is_being_hit = false
var is_atatcking = false
var is_transforming = false

var last_anim_direction = "down"
var move_direction_vector = Vector2(0,0)

var dash_timer = 0.0
var dash_cooldown_timer = 0.0

func _ready() -> void:
	
	saved_game = load_game()
	
	shooter.projectile_config = PROJECTILE_BASIC_CONFIG
	
	last_anim_direction = "down"
	animation_player.play("idle_down")
	
	is_transforming = false
	
	#camera setup
	follow_camera.ground_map_tile = ground_map_tile
	follow_camera.set_camera_limit()
	
	#health setup
	health.health_empty.connect(_on_health_empty)
	health.max_health = saved_game.max_health
	hurt_box.damaged.connect(_on_hit)
	Hud.health_bar.health = health
	
	#inventory setup
	Hud.inventory = inventory
	inventory.item_added.connect(_on_inventory_item_added)
	
	#deck builder setup
	
	deck_cards = saved_game.deck_cards
	if deck_cards.size() == 0 && not get_tree().current_scene.scene_file_path.contains("lobby"):
		build_deck()
	else:
		create_deck_hand()
	
	Globals.player = self
	get_tree().call_group("enemies", "update_target")

func _physics_process(_delta: float) -> void:

	if follow_camera.zoom.x != Globals.camera_zoom:
		follow_camera.zoom.x = Globals.camera_zoom
		follow_camera.zoom.y = Globals.camera_zoom

	hurt_box.can_be_hurt = can_take_damage()
	
	# Verificar se o cooldown do dash passou
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= _delta
	
	#hide card hand in lobby
	card_hand.visible = not get_tree().current_scene.scene_file_path.contains("lobby")
	
	if is_dying || is_being_hit || animation_player.current_animation.begins_with("attack"): return
	
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
			dash_cooldown_timer = dash_cooldown  # Começa o cooldown depois que o dash acabou
	
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
	if event.is_action_pressed("ui_test"):
		inventory.drop_item(0, global_position)
	
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
	var card_data = (card_hand.card_selected.card_config.CardData as CardDataProjectile)
	shooter.shoot_interval = card_data.shoot_interval
	shooter.shoot(last_anim_direction, card_data.DPS) 
	
func dash():
	# Só executa o dash se o cooldown já passou
	if dash_cooldown_timer <= 0:
		is_dashing = true
		dash_timer = dash_duration
		dash_cooldown_timer = dash_cooldown  # Reseta o cooldown após um dash

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.begins_with("attack_"):
		is_atatcking = false
	if anim_name.begins_with("hit"):
		is_being_hit = false
	if anim_name.begins_with("transform"):
		is_transforming = false
		var current_scene = get_tree().current_scene
		var first_node = current_scene.get_child(0)
		(first_node as Node2D).add_sibling.call_deferred(transformation)
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
	card_hand.select_card(card_number)
	
func can_take_damage():
	return is_dying == false && health.current_health > 0
	
func _on_deck_builder_opened() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true

func _on_deck_builder_closed(_deck_cards: Array[DeckCardItem], _cards_owned: Array[DeckCardItem]) -> void:
	
	#remove deck builder from screen
	get_tree().paused = false
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	remove_child(deck_builder)
	deck_builder.queue_free()
	
	# save deck created
	var new_saved_game: SavedGame = SavedGame.new()
	new_saved_game.deck_cards = _deck_cards
	new_saved_game.cards_owned = _cards_owned
	ResourceSaver.save(new_saved_game, "res://savegame.tres")
		
	deck_cards = _deck_cards
	create_deck_hand()

func build_deck():
	
	deck_builder = DECK_BUILDER.instantiate()
	deck_builder.cards_owned = saved_game.cards_owned
	deck_builder.deck_cards = saved_game.deck_cards
	deck_builder.closed.connect(_on_deck_builder_closed)
	deck_builder.opened.connect(_on_deck_builder_opened)
	add_child(deck_builder)
	deck_builder.update_deck()

func create_deck_hand():
	
	var deck_in_hand: Array[DeckCardItem] = []
	for deck_card_item in deck_cards:
		var card_copy = DeckCardItem.new()
		card_copy.card_config = deck_card_item.card_config
		card_copy.quantity = deck_card_item.quantity
		deck_in_hand.append(card_copy)
	
	card_hand = CARD_HAND.instantiate()
	card_hand.deck_cards = deck_in_hand
	card_hand.card_selected_changed.connect(_on_card_selected_changed)

	add_child(card_hand)
	card_hand.draw_cards(2)
	
func _on_card_selected_changed(card_selected: Card):
	
	print_debug(card_selected.card_config.CardType)
	
	if card_selected.card_config.CardType == Enums.CARD_TYPE.Projectile:
		shooter.projectile_config = (card_selected.card_config.CardData as CardDataProjectile).projectile_config
	if card_selected.card_config.CardType == Enums.CARD_TYPE.Transform:
		card_hand.use_selected_card()
		transform(card_selected.card_config)
	if card_selected.card_config.CardType == Enums.CARD_TYPE.Life:
		var health_card_data = card_selected.card_config.CardData as CardDataHealth
		var result: bool = health.increase_health(health_card_data.health)
		if result:
			card_hand.use_selected_card()
			
		card_hand.select_previous_card()

func _on_inventory_item_added(item: InventoryItem):
	
	var current_save_game = load("res://savegame.tres") as SavedGame
	
	if item.item_type == Enums.ITEM_TYPE.Card:
		
		var deck_card_item: DeckCardItem = null
	
		for card_owned: DeckCardItem in current_save_game.cards_owned:
			if card_owned.card_config  == item.resouce:
				deck_card_item = card_owned
				break
				
		if deck_card_item == null:
			deck_card_item = DeckCardItem.new()
			deck_card_item.card_config = item.resouce
			deck_card_item.quantity = 0
			current_save_game.cards_owned.append(deck_card_item)
		
		deck_card_item.quantity += 1
		card_hand.add_card_to_deck(deck_card_item)
		
	#current_save_game.items_picked_ids.append(item_id)
	ResourceSaver.save(current_save_game, "res://savegame.tres")
		
func transform(_transformation_card = CardConfig) -> void:
	
	if is_transforming: 
		return
	
	is_transforming = true
	Globals.player = self
	
	transformation = SAUSAGE_MONSTER.instantiate()
	transformation.position = global_position
	#transformation.ground_map_tile = ground_map_tile

	#transform from last transformation to new
	animation_player.play("transform")
	last_anim_direction = "down"

func load_game() -> SavedGame:
	return load("res://savegame.tres") as SavedGame
