class_name PickableGoldKey extends PickableItem

func _ready() -> void:
	inventory_item = InventoryItem.new()
	inventory_item.display_name = "Chave Dourada"
	inventory_item.description = "Chave Dourada"
	inventory_item.item_type = Enums.ITEM_TYPE.Key_Gold
	
	super._ready()
