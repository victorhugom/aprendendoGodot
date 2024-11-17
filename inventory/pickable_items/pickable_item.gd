class_name PickableItem extends Node

const SAVEGAME = preload("res://savegame.tres")

@onready var interactable: Interactable = $Interactable
@export var item_id: String

var inventory_item: InventoryItem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var item_found = SAVEGAME.items_picked_ids.filter(func(x): return x == item_id)
	if item_found.size() > 0:
		queue_free()
	
	interactable.interact_message = "Pegar %s" %inventory_item.display_name
	
func interact(body: Node) -> void:
	var inventory = body.get_node("Inventory") as Inventory
	assert(inventory != null, "Error: Inventory not found, check if inventory is in the actor, is in the root and with the name 'Inventory' case sensitive")
	
	inventory.add_item(inventory_item)
	queue_free()

func _on_interactable_interact(body: Node2D) -> void:
	self.interact(body)
