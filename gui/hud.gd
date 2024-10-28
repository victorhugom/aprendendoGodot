extends Control

@onready var health_bar: HBoxContainer = $CanvasLayer/HealthBar
@onready var card_hand: HBoxContainer = $CanvasLayer/CenterContainer/CardHand
@onready var animation_player: AnimationPlayer = $AnimationPlayer

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
