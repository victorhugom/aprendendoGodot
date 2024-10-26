extends "res://npc/npc.gd"

class_name Enemy
@onready var animation_sprite_2d: AnimatedSprite2D = $AnimationSprite2D

func _ready() -> void:
	super._ready()
	track_node(%Player)
	animation_sprite_2d.play("idle_down")
