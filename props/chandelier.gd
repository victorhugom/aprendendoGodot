extends Node2D

@onready var torch: AnimatedSprite2D = $Torch

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	torch.play("flame")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
