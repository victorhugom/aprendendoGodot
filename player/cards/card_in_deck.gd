class_name CardInDeck extends Button

@onready var quantity_label: RichTextLabel
@onready var h_box_container: HBoxContainer = $HBoxContainer

@export var card: Card
@export var quantity: int:
	get:
		return quantity
	set(value):
		quantity = value
		
		if quantity > 0:
			quantity_label.text = "x %s" % str(quantity)
			
			if quantity_label.visible == false:
				quantity_label.visible =  true
				quantity_label.custom_minimum_size = Vector2(40,0)
				quantity_label.update_minimum_size()
		else:
			quantity_label.visible =  false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	quantity_label = RichTextLabel.new()
	h_box_container.add_child(card)
	h_box_container.add_child(quantity_label)
	quantity = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
