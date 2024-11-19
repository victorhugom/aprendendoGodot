class_name Lobby extends Level

@onready var conversation_trigger: ConversationTrigger = $ConversationTrigger
@onready var player: Player = $Player

func _ready() -> void:
	conversation_trigger.can_play = player.deck_cards.size() <= 0
	
	super._ready()

func _on_cehck_deck_area_body_entered(_body: Node2D) -> void:
	conversation_trigger.can_play = player.deck_cards.size() <= 0
