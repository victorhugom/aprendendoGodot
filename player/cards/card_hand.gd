class_name CardHand extends HBoxContainer

const CARD_CONFIG_SINGLE_BASIC_SHOOT = preload("res://player/cards/cardsConfigs/card_config_single_basic_shoot.tres")
const CARD_CONFIG_DOUBLE_BASIC_SHOOT = preload("res://player/cards/cardsConfigs/card_config_double_basic_shoot.tres")
const CARD_CONFIG_TRIPLE_BASIC_SHOOT = preload("res://player/cards/cardsConfigs/card_config_triple_basic_shoot.tres")

const CARD = preload("res://player/cards/card.tscn")

var cards: Array[Card]
var card_selected: Card
var base_card = CARD_CONFIG_SINGLE_BASIC_SHOOT
var previous_card = CARD_CONFIG_SINGLE_BASIC_SHOOT

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_and_add_card(card_config: CardConfig, player: Player) -> void:
	var card = CARD.instantiate()
	card.card_config = card_config
	card.player = player
	
	add_child(card)
	cards.append(card)
	
func remove_card(card: Card):
	
	card_selected.destroy_card()
	card_selected.destroyed.connect(destroy_card)
	
func destroy_card(card: Card):
	remove_child(card)
	
	#remove from list
	var card_to_remove_idx = cards.find(card_selected)
	cards.remove_at(card_to_remove_idx)
	
	#select previous card or base card
	var previous_card_idx = cards.find(previous_card)
	if previous_card:
		select_card(previous_card_idx)
	else:
		select_card(1)
	
func draw_cards():
	create_and_add_card(base_card, player)
	create_and_add_card(CARD_CONFIG_DOUBLE_BASIC_SHOOT, player)
	create_and_add_card(CARD_CONFIG_TRIPLE_BASIC_SHOOT, player)
	select_card(1)

func select_card(card_number:int):
	
	if card_number <= cards.size():
		if card_selected:
			card_selected.in_use = false
		
		previous_card = card_selected
		card_selected = cards[card_number - 1]
		card_selected.in_use = true
		card_selected.execute_card()
		
func use_selected_card():
	card_selected.current_usage -= 1
	if card_selected.current_usage <= 0:
		remove_card(card_selected)
				
