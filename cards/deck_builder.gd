class_name DeckBuilder extends CanvasLayer

signal opened
signal closed(cards: Array[DeckCardItem])

const DECK_CARD = preload("res://cards/deckCard.tscn")

@onready var cards_container: HFlowContainer = $MarginContainer/GridContainer/VBoxContainer/ScrollContainer/CardsContainer
@onready var deck_container: VBoxContainer = $MarginContainer/GridContainer/VBoxContainer2/ScrollContainer2/DeckContainer
@onready var quantity_label: RichTextLabel = $MarginContainer/GridContainer/VBoxContainer2/HBoxContainer/QuantityLabel

@export var deck_cards: Array[DeckCardItem] = []	
@export var cards_owned: Array[CardConfig] = []	

@export var card_quantity: int:
	get:
		return card_quantity
	set(value):
		card_quantity = value
		
		if card_quantity > 0:
			quantity_label.text = str(card_quantity)
			quantity_label.visible =  true
		else:
			quantity_label.visible =  false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	create_card_table(cards_owned)
	opened.emit()

func create_card_table(cards: Array[CardConfig]):
	#create card table (all cards that can be selected)
	
	for card_config in cards:
		var deck_card = DECK_CARD.instantiate()
		deck_card.card_config = card_config
		
		var card_selected_callable = Callable(add_card_selected)
		card_selected_callable = card_selected_callable.bind(card_config)
		deck_card.connect("pressed", card_selected_callable)
		
		cards_container.add_child(deck_card)

func update_deck():
	
	if card_quantity >= 20:
		return
	
	clear_deck()
	card_quantity = 0
	for deck_card_item in deck_cards:
	
		var deck_card = DECK_CARD.instantiate()
		deck_card.card_config = deck_card_item.card_config
		deck_card.quantity = deck_card_item.quantity
		
		var card_remove_callable = Callable(remove_card_from_deck)
		card_remove_callable = card_remove_callable.bind(deck_card_item.card_config)
		deck_card.connect("pressed", card_remove_callable)
		
		deck_container.add_child(deck_card)
		card_quantity += deck_card_item.quantity
	
func clear_deck():
	
	var children =  deck_container.get_children()
	for child in children:
		deck_container.remove_child(child)

func add_card_selected(card_config: CardConfig) -> void:
	
	for deck_card_item:DeckCardItem in deck_cards:
		
		if deck_card_item.card_config == card_config:
			deck_card_item.quantity += 1
			update_deck()
			return
	
	var deck_card_item = DeckCardItem.new()
	deck_card_item.quantity = 1
	deck_card_item.card_config = card_config
	deck_cards.append(deck_card_item)
	
	update_deck()
	
func remove_card_from_deck(card_config) -> void:
	
	for deck_card_item:DeckCardItem in deck_cards:
	
		if deck_card_item.card_config == card_config:
			deck_card_item.quantity -= 1
			
			if deck_card_item.quantity <= 0:
				var idx = deck_cards.find(deck_card_item)
				deck_cards.remove_at(idx)
				update_deck()
				return

	update_deck()

func _on_create_deck_button_pressed() -> void:
	closed.emit(deck_cards)
