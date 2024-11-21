extends Control

@onready var health_bar: HealthBar = $CanvasLayer/HealthBar
@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer
@onready var commands: VBoxContainer = $CanvasLayer/Commands
@onready var mobile_buttons: CanvasLayer = $MobileButtons
@onready var virtual_joystick: VirtualJoystick = $"MobileButtons/Virtual Joystick"
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
func _ready():
	if OS.get_name() in ["Android", "iOS"]:
		commands.visible = false
		mobile_buttons.visible = true
	else:
		commands.visible = true
		mobile_buttons.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Rotation:
	if virtual_joystick and virtual_joystick.is_pressed:
		rotation = virtual_joystick.output.angle()
	
func _on_item_add_to_inventory(item: InventoryItem):
	if item.item_type == Enums.ITEM_TYPE.Key_Gold:
		keys_quantity += 1
		key_count_label.text = str(keys_quantity)
