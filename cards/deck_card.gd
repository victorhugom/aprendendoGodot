class_name DeckCard extends Button

const CARD = preload("res://cards/card.tscn")

@onready var quantity_label: RichTextLabel = $HBoxContainer/QuantityLabel
@onready var h_box_container: HBoxContainer = $HBoxContainer

@export var card_config: CardConfig
@export var quantity: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var card = CARD.instantiate()
	card.card_config = card_config
	
	h_box_container.add_child(card)
	
	if quantity > 0:
		quantity_label.text = "x %s" % str(quantity)
		
		if quantity_label.visible == false:
			quantity_label.visible =  true
			quantity_label.custom_minimum_size = Vector2(40,0)
			quantity_label.update_minimum_size()
	else:
		quantity_label.visible =  false
