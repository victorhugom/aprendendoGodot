class_name PickableItem extends Node

@onready var interactable: Interactable = $Interactable

@export var inventoryItem: InventoryItem

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interactable.interact_message = "Pegar %s" %inventoryItem.display_name

func interact(body: Node) -> void:
	var inventory = body.get_node("Inventory") as Inventory
	assert(inventory != null, "Error: Inventory not found, check if inventory is in the actor, is in the root and with the name 'Inventory' case sensitive")
	
	inventory.add_item(inventoryItem)
	queue_free()
