class_name CardInDeck extends Button

@onready var quantity_label: RichTextLabel = $HBoxContainer/QuantityLabel

@export var card: Card
@export var quantity: int:
	get:
		return quantity
	set(value):
		quantity = value
		
		if quantity > 1:
			quantity_label.text = str(quantity)
			quantity_label.visible =  true
		else:
			quantity_label.visible =  false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(card)
	quantity = 1
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
