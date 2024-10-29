extends Node2D

@onready var candle: AnimatedSprite2D = $"Candle"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	candle.play("candleflame")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
