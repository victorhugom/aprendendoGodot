extends Node2D

@onready var conversation_trigger: ConversationTrigger = $ConversationTrigger
@onready var player: Player = $Player

func _ready() -> void:
	conversation_trigger.can_play = player.deck_cards.size() <= 0

func _on_cehck_deck_area_body_entered(body: Node2D) -> void:
	conversation_trigger.can_play = player.deck_cards.size() <= 0
