class_name DeckCard extends Button

const CARD = preload("res://cards/card.tscn")

@onready var container: Control = $MarginContainer/Container
@onready var quantity_label_box: CenterContainer = $MarginContainer/Container/QuantityLabelBox
@onready var quantity_label: RichTextLabel = $MarginContainer/Container/QuantityLabelBox/QuantityLabel

@export var card_config: CardConfig
@export var quantity: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var card = CARD.instantiate()
	card.card_config = card_config
	
	container.add_child(card)
	card.position = Vector2(0, 15)
	
	container.move_child(quantity_label_box, -1)
	
	quantity_label.text = "0%s" % str(quantity) if quantity < 10 else  "%s" % str(quantity) 
	
