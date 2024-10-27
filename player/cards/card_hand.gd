class_name CardHand extends HBoxContainer

const CARD_CONFIG_DOUBLE_BASIC_SHOOT = preload("res://player/cards/cardsConfigs/card_config_double_basic_shoot.tres")
const CARD_CONFIG_TRIPLE_BASIC_SHOOT = preload("res://player/cards/cardsConfigs/card_config_triple_basic_shoot.tres")

const CARD = preload("res://player/cards/card.tscn")

var cards: Array[Card]
var card_selected: Card
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
	
func remove_Card(id: int):
	pass
	
func draw_cards():
	create_and_add_card(CARD_CONFIG_DOUBLE_BASIC_SHOOT, player)
	create_and_add_card(CARD_CONFIG_TRIPLE_BASIC_SHOOT, player)

func select_card(card_number:int):
	
	if card_number <= cards.size():
		if card_selected:
			card_selected.in_use = false
		
		card_selected = cards[card_number - 1]
		card_selected.in_use = true
		card_selected.execute_card()
				
