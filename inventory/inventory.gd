class_name Inventory extends Node2D

var inventory_data: InventoryData
const INVENTORY_DATA_SAVE_PATH:= "user://inventory_data.tres"

signal item_added(item: InventoryItem)

var items: Array[InventoryItem] = []

func _ready() -> void:
	
	inventory_data = load_inventory_data()
	items = inventory_data.items as Array[InventoryItem]

func add_item(item: InventoryItem):
	items.append(item)
	item_added.emit(item)
	
	ResourceSaver.save(inventory_data, INVENTORY_DATA_SAVE_PATH)
	
func has_item(item_type: Enums.ITEM_TYPE) -> Array[InventoryItem]:
	var items_found: Array[InventoryItem] = []
	for item in items:
		if item.item_type == item_type:
			items_found.append(item)
			
	return items_found
	
static func load_inventory_data():
	if ResourceLoader.exists(INVENTORY_DATA_SAVE_PATH):
		return SafeResourceLoader.load(INVENTORY_DATA_SAVE_PATH)
	else:
		return InventoryData.new()
