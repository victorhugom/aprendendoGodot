extends Node2D

const CHAT_BOX = preload("res://conversation/chatBox.tscn")

@export var conversation: Conversation

var chat_box: ChatBox
var player: Player

func _on_interactable_interact(body: Node2D) -> void:
	player = body as Player
	
	chat_box = CHAT_BOX.instantiate()
	chat_box.conversation = conversation
	chat_box.next_message.connect(_on_next_message)
	chat_box.cancel_message.connect(_on_cancel_message)
	chat_box.end_conversation.connect(_on_end_conversation)
	get_tree().root.add_child(chat_box)

func _on_next_message(message: ChatMessage):
	print_debug("next_message: %s" %message.message)
	
func _on_cancel_message(message: ChatMessage):
	print_debug("cancel_message: %s" %message.message)
	
func _on_end_conversation():
	print_debug("end_message")

func _on_interactable_body_exited(_body: Node2D) -> void:
	if chat_box != null:
		var tween = get_tree().create_tween()
		tween.tween_callback(chat_box.close_conversation).set_delay(.5)
