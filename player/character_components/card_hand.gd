class_name CardHand extends CanvasLayer

signal card_selected_changed(card: Card)

const CARD_CONFIG_BASIC_SHOOT = preload("res://cards/configs/card_config_basic_shoot.tres")

const CARD_CONFIG_AIR_SHOOT = preload("res://cards/configs/card_config_air_shoot.tres")
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
var base_card: CardConfig = CARD_CONFIG_BASIC_SHOOT

var _cards_history: Array[Card] = []

var card_quantity: int:
	get:
		return deck_cards.reduce(func(accum, elem): return accum + elem.quantity, 0)

func add_card_to_deck(item: DeckCardItem):
	
	# for each deck card, if is already in deck increase quantity
	for card in deck_cards:
		if card.card_config == item.card_config:
			card.quantity += 1
			return
	
	#if deck is not in deck cards, create a new one and add it
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
	if card.is_being_destroyed:
		return
	
	# remove last card from list of used cards
	var left_items = _cards_history.filter(func(element: Card): return element.id != card.id)
	_cards_history =  left_items
		
	select_previous_card()		
	
	card.destroy_card()
	card.destroyed.connect(destroy_card)
	
func destroy_card(card: Card):
	
	#remove from list
	var card_to_remove_idx = cards.find(card)
	cards.remove_at(card_to_remove_idx)
	
	# remove node and free card from memory
	card_container.remove_child(card)
	card.queue_free()
	
	update_shortcut_ids()
	
	
func draw_cards(amount_to_draw: int = 1) -> bool:
	
	#has too many cards in hand, cannot draw cards
	if cards.size() >= 3:
		return false
	
	#has no card in hand, create base card
	if cards.size() == 0:
		create_and_add_card(base_card)
		select_card(1)
		
	#has no card in hand, cannot draw cards
	if deck_cards.size() == 0:
		return false
	
	if deck_cards.size() > 0:
		for i in range(0, amount_to_draw):
			
			if deck_cards.size() <= 0:
				return false
			
			#pick a random card
			var card_index = randi_range(0, deck_cards.size() - 1) 
			var card_in_deck:  DeckCardItem = deck_cards[card_index]
			var card_config = card_in_deck.card_config
			
			card_in_deck.quantity -= 1
			
			#remove this card if it's the last one
			if card_in_deck.quantity == 0: 
				deck_cards.remove_at(card_index)
			
			create_and_add_card(card_config) #create card and add to hand
	
	if card_selected == null && cards.size() != 0:
		select_card(1)
	
	update_shortcut_ids()
	card_quantity_label.text = "%s x" %card_quantity
	return true

func select_card(card_number:int):

	# if card in range
	if card_number > 0 && card_number <= cards.size():
		
		# save previous card a deselect it (not in use)
		if card_selected != null:
			card_selected.in_use = false

		# udpate card selected
		card_selected = cards[card_number - 1]
		card_selected.in_use = true
		card_selected_changed.emit(card_selected)
		
		if card_selected.card_config.CardType != Enums.CARD_TYPE.Life:
				_cards_history.append(card_selected)
	
func select_previous_card():
	
	var previous_card_idx = 0

	var previous_card: Card = _cards_history[_cards_history.size() - 1]
	if previous_card != null:
		previous_card_idx = cards.find(previous_card)
			
	select_card(previous_card_idx + 1)
	
func use_selected_card():
	card_selected.current_usage -= 1
	if card_selected.current_usage <= 0:
		remove_card(card_selected)
