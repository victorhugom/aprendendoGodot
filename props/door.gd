extends Area2D

@onready var marker_2d: Marker2D = $Marker2D

@export var door_scene_destination_path: String
@export var door_destination_scene_name: String #where the door goes
@export var door_curr_scene_name: String #where the door is
@export var player: Player

var near_door = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Globals.last_scene_name ==  door_destination_scene_name:
		player.global_position = marker_2d.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_body_entered(_body: Node2D) -> void:
	InteractionCall.show_interaction.emit("Entrar")
	near_door = true

func _on_body_exited(_body: Node2D) -> void:
	InteractionCall.hide_interaction.emit()
	near_door = false
	
func _input(event):
	if near_door && event.is_action_pressed("ui_interact"):
		Globals.last_scene_name = door_curr_scene_name
		enter()

func enter():
	get_tree().change_scene_to_file(door_scene_destination_path)
