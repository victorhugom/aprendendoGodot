extends Area2D

@onready var marker_2d: Marker2D = $Marker2D

@export var disabled := false
@export_file("*.tscn") var target_scene_path

var near_door = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if target_scene_path == Globals.previous_scence_path && Globals.player:
		get_tree().root.add_child(Globals.player)
		Globals.player.global_position = marker_2d.global_position

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
		
		Globals.next_scence_path = target_scene_path
		Globals.previous_scence_path = get_tree().current_scene.scene_file_path
		
		Globals.player.get_parent().remove_child(Globals.player)		
		get_tree().change_scene_to_packed(Globals.loading_screen)
