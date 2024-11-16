class_name ConversationTrigger extends Area2D

const CHAT_BOX = preload("res://conversation/chatBox.tscn")

signal conversation_finished

@export var conversation: Conversation
@export var play_once:= false

var chat_box: ChatBox 
var played:= false
var can_play:= true

func _on_body_entered(_body: Node2D) -> void:
	
	if can_play == false:
		return 
			
	if played && play_once:
		return

	chat_box = CHAT_BOX.instantiate()
	chat_box.conversation = conversation
	chat_box.next_message.connect(_on_next_message)
	chat_box.cancel_message.connect(_on_cancel_message)
	chat_box.end_conversation.connect(_on_end_conversation)
	get_tree().root.add_child(chat_box)

func _on_body_exited(_body: Node2D) -> void:
	if chat_box != null:
		var tween = get_tree().create_tween()
		tween.tween_callback(chat_box.close_conversation).set_delay(.5)

func _on_next_message(message: ChatMessage):
	print_debug("next_message: %s" %message.message)
	
func _on_cancel_message(message: ChatMessage):
	print_debug("cancel_message: %s" %message.message)
	
func _on_end_conversation():
	print_debug("end_conversation")
	played = true
	conversation_finished.emit()
