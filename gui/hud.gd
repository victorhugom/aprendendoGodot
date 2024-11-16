extends Control

@onready var health_bar: HealthBar = $CanvasLayer/HealthBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var key_count_label: RichTextLabel = $CanvasLayer/KeyBox/CenterContainer/HBoxContainer/KeyCountLabel

var inventory: Inventory:
	get:
		return inventory
	set(value):
		inventory = value
		inventory.item_added.connect(_on_item_add_to_inventory)
		
		var keys = inventory.has_item(Enums.ITEM_TYPE.Key_Gold)
		keys_quantity = keys.size()
		key_count_label.text = str(keys_quantity)
		
		
var keys_quantity:= 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _on_item_add_to_inventory(item: InventoryItem):
	if item.item_type == Enums.ITEM_TYPE.Key_Gold:
		keys_quantity += 1
		key_count_label.text = str(keys_quantity)
