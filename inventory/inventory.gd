class_name Inventory extends Node2D

var items: Array[InventoryItem] = []

func add_item(item: InventoryItem):
	items.append(item)
	
func has_item(item_type: Enums.ITEM_TYPE) -> InventoryItem:
	for item in items:
		if item.item_type == item_type:
			return item
	return null
	
	
	
