extends Control

signal opened
signal closed

const CARD_IN_DECK = preload("res://player/cards/cardInDeck.tscn")
const CARD = preload("res://player/cards/card.tscn")

const CARD_CONFIG_AIR_SHOOT = preload("res://player/cards/cardsConfigs/card_config_air_shoot.tres")
const CARD_CONFIG_BASIC_SHOOT = preload("res://player/cards/cardsConfigs/card_config_basic_shoot.tres")
const CARD_CONFIG_EARTH_SHOOT = preload("res://player/cards/cardsConfigs/card_config_earth_shoot.tres")
const CARD_CONFIG_FIRE_SHOOT = preload("res://player/cards/cardsConfigs/card_config_fire_shoot.tres")
const CARD_CONFIG_HEALTH_POTION = preload("res://player/cards/cardsConfigs/card_config_health_potion.tres")
const CARD_CONFIG_TRANSFORM_SAUSAGE = preload("res://player/cards/cardsConfigs/card_config_transform_sausage.tres")
const CARD_CONFIG_WATER_SHOOT = preload("res://player/cards/cardsConfigs/card_config_water_shoot.tres")

@onready var cards_container: HFlowContainer = $MarginContainer/GridContainer/VBoxContainer/ScrollContainer/CardsContainer
@onready var deck_container: VBoxContainer = $MarginContainer/GridContainer/VBoxContainer2/ScrollContainer2/DeckContainer
@onready var quantity_label: RichTextLabel = $MarginContainer/GridContainer/VBoxContainer2/HBoxContainer/QuantityLabel

var card_configs = [
 CARD_CONFIG_AIR_SHOOT,
 #CARD_CONFIG_BASIC_SHOOT,
 CARD_CONFIG_EARTH_SHOOT,
 CARD_CONFIG_FIRE_SHOOT,
 CARD_CONFIG_HEALTH_POTION,
 CARD_CONFIG_TRANSFORM_SAUSAGE,
 CARD_CONFIG_WATER_SHOOT,
]

@export var cards_in_deck: Array[CardInDeck] = []	
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
	
	for cc in card_configs:
		var card_in_deck = CARD_IN_DECK.instantiate()
		var card = CARD.instantiate()
		
		card_in_deck.card = card
		card.card_config = cc
		
		var callable = Callable(add_card_selected)
		callable = callable.bind(cc)
		card_in_deck.pressed.connect(callable)
		
		cards_container.add_child(card_in_deck)
	
	opened.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_card_selected(card_config) -> void:
	
	if card_quantity >= 20:
		return
	
	#if card exists increment value
	for existing_card: CardInDeck in cards_in_deck:
		if existing_card.card.card_config == card_config:
			existing_card.quantity += 1
			card_quantity+=1
			return
			
	# create new card
	var card_in_deck = CARD_IN_DECK.instantiate()
	var card = CARD.instantiate()
	card_in_deck.card = card
	card.card_config = card_config
	
	var callable = Callable(remove_card_from_deck)
	callable = callable.bind(card_config)
	card_in_deck.pressed.connect(callable)

	#add card to tree and list
	deck_container.add_child(card_in_deck)
	cards_in_deck.append(card_in_deck)

	card_quantity+=1
	
func remove_card_from_deck(card_config) -> void:
	for existing_card: CardInDeck in cards_in_deck:
		if existing_card.card.card_config == card_config:
			existing_card.quantity -= 1
			card_quantity-=1
			
			if existing_card.quantity <= 0:
				var existin_card_id = cards_in_deck.find(existing_card)
				cards_in_deck.remove_at(existin_card_id)
				existing_card.queue_free()
				
func _on_create_deck_button_pressed() -> void:
	closed.emit()
