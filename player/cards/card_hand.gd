class_name CardHand extends HBoxContainer

const CARD_CONFIG_AIR_SHOOT = preload("res://player/cards/cardsConfigs/card_config_air_shoot.tres")
const CARD_CONFIG_BASIC_SHOOT = preload("res://player/cards/cardsConfigs/card_config_basic_shoot.tres")
const CARD_CONFIG_EARTH_SHOOT = preload("res://player/cards/cardsConfigs/card_config_earth_shoot.tres")
const CARD_CONFIG_FIRE_SHOOT = preload("res://player/cards/cardsConfigs/card_config_fire_shoot.tres")
const CARD_CONFIG_WATER_SHOOT = preload("res://player/cards/cardsConfigs/card_config_water_shoot.tres")

const CARD_CONFIG_TRANSFORM_SAUSAGE = preload("res://player/cards/cardsConfigs/card_config_transform_sausage.tres")
const CARD_CONFIG_HEALTH_POTION = preload("res://player/cards/cardsConfigs/card_config_health_potion.tres")

const CARD = preload("res://player/cards/card.tscn")

var cards: Array[Card]
var card_deck: Array[CardInDeck]
var card_selected: Card
var base_card = CARD_CONFIG_BASIC_SHOOT
var previous_card = CARD_CONFIG_BASIC_SHOOT

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func create_and_add_card(card_config: CardConfig, current_player: Player) -> void:
	var card = CARD.instantiate()
	card.card_config = card_config
	card.player = current_player
	
	add_child(card)
	cards.append(card)
	
func add_card(new_card: Card, current_player: Player):
	new_card.player = current_player
	add_child(new_card)
	cards.append(new_card)
	
func remove_card(card: Card):
	card.destroy_card()
	card.destroyed.connect(destroy_card)
	
func destroy_card(card: Card):
	remove_child(card)
	
	#remove from list
	var card_to_remove_idx = cards.find(card_selected)
	cards.remove_at(card_to_remove_idx)
	
	#select previous card or base card
	var previous_card_idx = cards.find(previous_card)
	if previous_card:
		select_card(previous_card_idx + 1)
	else:
		select_card(1)
	
func draw_cards():
	
	if cards.size() >= 3:
		return
		#TODO: message, cannot draw cards
	
	if cards.size() == 0:
		create_and_add_card(base_card, player)
	
	if card_deck.size() > 0:
		for i in range(0, 2):
			var card_index = randi_range(0, card_deck.size() - 1)
			var card_in_deck = (card_deck[card_index] as CardInDeck)
			var card_config = card_in_deck.card.card_config
			
			card_in_deck.quantity -= 1
			if card_in_deck.quantity == 0:
				card_deck.remove_at(card_index)
			
			create_and_add_card(card_config, player)
	
	if card_selected == null && cards.size() != 0:
		select_card(1)

func select_card(card_number:int):
	
	if card_number <= cards.size():
		if card_selected:
			card_selected.in_use = false
		
		previous_card = card_selected
		card_selected = cards[card_number - 1]
		card_selected.in_use = true
		
		if card_selected.card_config.CardType == Enums.CARD_TYPE.Life && player.health >= player.max_health:
			var idx = cards.find(previous_card)
			select_card(idx + 1)
			return
		
		card_selected.execute_card()
		
		if card_selected.card_config.CardType == Enums.CARD_TYPE.Transform:
			use_selected_card()
		if card_selected.card_config.CardType == Enums.CARD_TYPE.Life:
			use_selected_card()
				
		
func use_selected_card():
	card_selected.current_usage -= 1
	if card_selected.current_usage <= 0:
		remove_card(card_selected)			
