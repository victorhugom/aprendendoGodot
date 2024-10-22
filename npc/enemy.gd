extends "res://npc/npc.gd"

class_name Enemy

func _ready() -> void:
	super._ready()
	track_node(%Player)
