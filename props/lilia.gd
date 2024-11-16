extends Node2D

const LILIA_CHOOSE_CARDS_CONVERSATION = preload("res://conversation/conversations/lilia_choose_cards_conversation.tres")
const CHAT_BOX = preload("res://conversation/chatBox.tscn")

var player: Player

# Called when the node enters the scene tree for the first time.
func _on_interactable_interact(body: Node2D) -> void:
	player = body as Player
	player.process_mode = Node.PROCESS_MODE_DISABLED
	
	var chat_box = CHAT_BOX.instantiate()
	chat_box.conversation = LILIA_CHOOSE_CARDS_CONVERSATION
	chat_box.next_message.connect(_on_next_message)
	chat_box.cancel_message.connect(_on_cancel_message)
	chat_box.end_conversation.connect(_on_end_conversation)
	get_tree().root.add_child(chat_box)

func _on_next_message(message: ChatMessage):
	print_debug("next_message: %s" %message.message)
	
func _on_cancel_message(message: ChatMessage):
	print_debug("cancel_message: %s" %message.message)
	
func _on_end_conversation():
	player.process_mode = Node.PROCESS_MODE_INHERIT
	player.build_deck()
