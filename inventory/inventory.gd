class_name Inventory extends Node2D

signal item_added(item: InventoryItem)

var items: Array[InventoryItem] = []

func add_item(item: InventoryItem):
	item_added.emit(item)
	items.append(item)
	
func has_item(item_type: Enums.ITEM_TYPE) -> Array[InventoryItem]:
	var items_found: Array[InventoryItem] = []
	for item in items:
		if item.item_type == item_type:
			items_found.append(item)
			
	return items_found
	
	
	
