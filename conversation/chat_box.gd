class_name ChatBox extends CanvasLayer

signal next_message(message: ChatMessage)
signal cancel_message(message: ChatMessage)
signal end_conversation

@onready var message_label: RichTextLabel = $HBoxContainer/ColorRect/MarginContainer/PanelContainer/MarginContainer/Message
@onready var char_name_label: RichTextLabel = $HBoxContainer/ColorRect/MarginContainer/PanelContainer/CharName
@onready var cancel_button: Control = $HBoxContainer/ColorRect/HBoxContainer/CancelButton

var conversation: Conversation
var conversation_idx = 0
var current_message: ChatMessage

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show_message(0)

func show_message(idx: int):
	
	if idx > conversation.messages.size() - 1:
		close_conversation()
	else:
		conversation_idx = idx
		current_message = conversation.messages[idx]
		
		if current_message:
			message_label.text = current_message.message
			char_name_label.text = current_message.char_name
			next_message.emit(current_message)
			cancel_button.visible = current_message.has_cancel

func close_conversation():
	end_conversation.emit()
	queue_free()	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_next_message"):
		show_message(conversation_idx + 1)
	if event.is_action_pressed("ui_cancel_message") && current_message.has_cancel:
		cancel_message.emit(current_message)
		show_message(conversation_idx + 1)
	
	
	