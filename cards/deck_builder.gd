class_name DeckBuilder extends CanvasLayer

signal opened
signal closed(deck_cards: Array[DeckCardItem], cards_owned: Array[DeckCardItem])

const DECK_CARD = preload("res://cards/deckCard.tscn")

@onready var cards_container: HFlowContainer = $MarginContainer/GridContainer/VBoxContainer/ScrollContainer/CardsContainer
@onready var deck_container: VBoxContainer = $MarginContainer/GridContainer/VBoxContainer2/ScrollContainer2/CenterContainer/DeckContainer

@onready var quantity_label: RichTextLabel = $MarginContainer/GridContainer/VBoxContainer2/HBoxContainer/QuantityLabel

@export var deck_cards: Array[DeckCardItem] = []	

@export var cards_owned: Array[DeckCardItem] = []
@export var card_quantity: int:
	get:
		return card_quantity
	set(value):
		card_quantity = value
		
		quantity_label.text = "0%s" %card_quantity if card_quantity < 10 else "%s" %card_quantity

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	update_card_table()
	opened.emit()

func update_card_table():
	#create card table (all cards that can be selected)
	
	clear_table()
	
	for card_owned: DeckCardItem in cards_owned:
		var deck_card = DECK_CARD.instantiate()
		deck_card.card_config = card_owned.card_config
		deck_card.quantity = card_owned.quantity
		
		var card_add_callable = Callable(add_card_selected)
		card_add_callable = card_add_callable.bind(card_owned.card_config)
		deck_card.connect("pressed", card_add_callable)
		
		cards_container.add_child(deck_card)

func update_deck():
	
	if card_quantity >= 20:
		return
	
	clear_deck()
	card_quantity = 0
	for deck_card_item: DeckCardItem in deck_cards:
	
		var deck_card = DECK_CARD.instantiate()
		deck_card.card_config = deck_card_item.card_config
		deck_card.quantity = deck_card_item.quantity
		
		var card_remove_callable = Callable(remove_card_from_deck)
		card_remove_callable = card_remove_callable.bind(deck_card_item.card_config)
		deck_card.connect("pressed", card_remove_callable)
		
		deck_container.add_child(deck_card)
		card_quantity += deck_card_item.quantity
	
func clear_deck():
	
	var children = deck_container.get_children()
	for child in children:
		deck_container.remove_child(child)

func clear_table():
	
	var children = cards_container.get_children()
	for child in children:
		cards_container.remove_child(child)

func add_card_selected(card_config: CardConfig) -> void:
	
	#add card to deck
	var deck_card_item = null
	
	#deck card exists
	for existing_deck_card_item:DeckCardItem in deck_cards:
		#card found update the quantity
		if existing_deck_card_item.card_config == card_config:
			existing_deck_card_item.quantity += 1
			deck_card_item = existing_deck_card_item
			break
	
	#card not found create card
	if deck_card_item == null:
		deck_card_item = DeckCardItem.new()
		deck_card_item.quantity = 1
		deck_card_item.card_config = card_config
		deck_cards.append(deck_card_item)
	
	update_deck()
	
	# update card table
	for card_owned: DeckCardItem in cards_owned:
		#update card quantity
		if card_owned.card_config ==  card_config:
			card_owned.quantity -= 1
			#card quantity equal 0 remove it from list
			if card_owned.quantity <= 0:
				var idx_to_remove = cards_owned.find(card_owned)
				cards_owned.remove_at(idx_to_remove)
				
			break
			
	update_card_table()
	
	
func remove_card_from_deck(card_config) -> void:
	
	for deck_card_item:DeckCardItem in deck_cards:
		
		#remove 1 quantity from deck
		if deck_card_item.card_config == card_config:
			deck_card_item.quantity -= 1
			
			# if all cards remove remove if from deck
			if deck_card_item.quantity <= 0:
				var idx = deck_cards.find(deck_card_item)
				deck_cards.remove_at(idx)
				
			break

	update_deck()
	
	# update card table
	var card_owned = null
	
	#card is in owned cards
	for existing_deck_card_item:DeckCardItem in cards_owned:
		
		#card found update the quantity
		if existing_deck_card_item.card_config == card_config:
			existing_deck_card_item.quantity += 1
			card_owned = existing_deck_card_item
			break
	
	#card not found create card
	if card_owned == null:
		card_owned = DeckCardItem.new()
		card_owned.quantity = 1
		card_owned.card_config = card_config
		cards_owned.append(card_owned)
			
	update_card_table()

func _on_create_deck_button_pressed() -> void:
	closed.emit(deck_cards, cards_owned)
