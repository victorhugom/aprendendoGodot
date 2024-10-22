extends Control

signal show_interaction(text: String)
signal hide_interaction

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var rich_text_label: RichTextLabel = $CanvasLayer/HBoxContainer/CenterContainer/RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	canvas_layer.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_show_interaction(text) -> void:
	canvas_layer.visible = true
	rich_text_label.text = text

func _on_hide_interaction() -> void:
	canvas_layer.visible = false
