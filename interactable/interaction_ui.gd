class_name InteractionUI extends Control

@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var rich_text_label: RichTextLabel = $CanvasLayer/HBoxContainer/CenterContainer/RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	canvas_layer.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func show_interaction(text) -> void:
	canvas_layer.visible = true
	rich_text_label.text = text

func hide_interaction() -> void:
	canvas_layer.visible = false
