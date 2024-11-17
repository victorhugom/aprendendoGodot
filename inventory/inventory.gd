class_name Inventory extends Node2D

const INVENTORY_DATA = preload("res://inventory_data.tres")

signal item_added(item: InventoryItem)

var items: Array[InventoryItem] = []

func _ready() -> void:
	items = INVENTORY_DATA.items as Array[InventoryItem]

func add_item(item: InventoryItem):
	items.append(item)
	item_added.emit(item)
	
	ResourceSaver.save(INVENTORY_DATA, INVENTORY_DATA.resource_path)
	
func has_item(item_type: Enums.ITEM_TYPE) -> Array[InventoryItem]:
	var items_found: Array[InventoryItem] = []
	for item in items:
		if item.item_type == item_type:
			items_found.append(item)
			
	return items_found
	
