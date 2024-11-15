extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var loop:= false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("default")
	
func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	if loop:
		animation_player.play("default")
	else:
		queue_free()
