extends HBoxContainer

const CARD = preload("res://player/cards/card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_and_add_card(card_config: CardConfig, player: Player) -> Card:
	var card = CARD.instantiate()
	card.card_config = card_config
	card.player = player
	
	add_child(card)
	return card
	
func add_card(card: Card):
	add_child(card)
		
func remove_Card(id: int):
	pass
				
