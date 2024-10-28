extends Control

@onready var health_bar: HBoxContainer = $CanvasLayer/HealthBar
@onready var card_hand: CardHand = $CanvasLayer/CenterContainer/CardHand
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var deck_builder: Control = $CanvasLayer/DeckBuilder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func show_hand() -> void:
	animation_player.play("show")
	
func hide_hand() -> void:
	animation_player.play("hide")

func _on_deck_builder_opened() -> void:
	get_tree().paused = true

func _on_deck_builder_closed() -> void:
	deck_builder.visible = false
	card_hand.card_deck = deck_builder.cards_in_deck
	get_tree().paused = false
