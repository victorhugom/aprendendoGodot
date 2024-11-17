class_name CardHand extends CanvasLayer

signal card_selected_changed(card: Card)

const CARD_CONFIG_AIR_SHOOT = preload("res://cards/configs/card_config_air_shoot.tres")
const CARD_CONFIG_BASIC_SHOOT = preload("res://cards/configs/card_config_basic_shoot.tres")
const CARD_CONFIG_EARTH_SHOOT = preload("res://cards/configs/card_config_earth_shoot.tres")
const CARD_CONFIG_FIRE_SHOOT = preload("res://cards/configs/card_config_fire_shoot.tres")
const CARD_CONFIG_WATER_SHOOT = preload("res://cards/configs/card_config_water_shoot.tres")

const CARD_CONFIG_TRANSFORM_SAUSAGE = preload("res://cards/configs/card_config_transform_sausage.tres")
const CARD_CONFIG_HEALTH_POTION = preload("res://cards/configs/card_config_health_potion.tres")

const CARD = preload("res://cards/card.tscn")

@onready var card_container: HBoxContainer = $CenterContainer/CardContainer
@onready var card_quantity_label: RichTextLabel = $BuyCards/HBoxContainer2/CardQuantityLabel

var cards: Array[Card]
var deck_cards: Array[DeckCardItem]
var card_selected: Card
var base_card = CARD_CONFIG_BASIC_SHOOT
var previous_card = CARD_CONFIG_BASIC_SHOOT

var card_quantity: int:
	get:
		return deck_cards.reduce(func(accum, elem): return accum + elem.quantity, 0)

func add_card_to_deck(item: DeckCardItem):
	for card in deck_cards:
		if card.card_config == item.card_config:
			card.quantity += 1
			return
		
	var new_deck_card = DeckCardItem.new()
	new_deck_card.quantity = 1
	new_deck_card.card_config = item.card_config
	deck_cards.append(new_deck_card)
	card_quantity_label.text = "%s x" %card_quantity

func create_and_add_card(card_config: CardConfig) -> void:
	var card = CARD.instantiate()
	card.card_config = card_config
	cards.append(card)
	
	card_container.add_child(card)

func update_shortcut_ids():
	for idx in range(0, cards.size()):
		cards[idx].shortcut_id = idx + 1
	
func remove_card(card: Card):
	card.destroy_card()
	card.destroyed.connect(destroy_card)
	
func destroy_card(card: Card):
	
	card.queue_free()
	
	#remove from list
	var card_to_remove_idx = cards.find(card_selected)
	cards.remove_at(card_to_remove_idx)
	
	#select previous card or base card
	var previous_card_idx = cards.find(previous_card)
	if previous_card:
		select_card(previous_card_idx + 1)
	else:
		select_card(1)
		
	update_shortcut_ids()
	
func draw_cards(amount_to_draw: int = 1) -> bool:
	
	if cards.size() >= 3:
		#has too many cards in hand, cannot draw cards
		return false
	
	if cards.size() == 0:
		#has no card in hand, create base card
		create_and_add_card(base_card)
		select_card(1)
		
	if deck_cards.size() == 0:
		#has no card in hand, cannot draw cards
		return false
	
	if deck_cards.size() > 0:
		for i in range(0, amount_to_draw):
			
			if deck_cards.size() <= 0:
				return false
			
			var card_index = randi_range(0, deck_cards.size() - 1) #pick a random cards
			var card_in_deck = (deck_cards[card_index] as DeckCardItem)
			var card_config = card_in_deck.card_config
			
			card_in_deck.quantity -= 1
			if card_in_deck.quantity == 0: #remove this card if it's the last one
				deck_cards.remove_at(card_index)
			
			create_and_add_card(card_config) #create card and add to hand
	
	if card_selected == null && cards.size() != 0:
		select_card(1)
	
	update_shortcut_ids()
	card_quantity_label.text = "%s x" %card_quantity
	return true

func select_card(card_number:int):

	if card_number <= cards.size():
		if card_selected:
			card_selected.in_use = false
		
		previous_card = card_selected
		card_selected = cards[card_number - 1]
		card_selected.in_use = true
		card_selected_changed.emit(card_selected)
	
func select_previous_card():
	
	var previous_card_idx = cards.find(previous_card)
	select_card(previous_card_idx + 1)
	
func use_selected_card():
	card_selected.current_usage -= 1
	if card_selected.current_usage <= 0:
		remove_card(card_selected)
