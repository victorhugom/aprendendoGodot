class_name PickableCard extends PickableItem

const CARD = preload("res://cards/card.tscn")

@onready var card: Card = $Interactable/Card

@export var card_config: CardConfig
@export_category("Audio Settings")
@export var audio_stream: AudioStream
#endregion

func _ready() -> void:
	
	card.card_config = card_config
	card._ready()
	
	inventory_item = InventoryItem.new()
	inventory_item.display_name = card.card_config.Name
	inventory_item.description = "Carta %s" %card.card_config.Name
	inventory_item.item_type = Enums.ITEM_TYPE.Card
	inventory_item.resouce = card_config
	
	super._ready()
