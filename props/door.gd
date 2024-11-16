class_name Door extends Node2D

@onready var marker_2d: Marker2D = $Marker2D
@onready var interactable: Interactable = $Interactable

@export_file("*.tscn") var target_scene_path: String
@export var only_exit:= false

@export_category("Requires Key")
@export var requires_key:= false
@export var required_quantity:= 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	interactable.requires_item = requires_key
	interactable.required_item_quantity = required_quantity
	
	if only_exit: 
		return
	
	if target_scene_path == Globals.previous_scence_path && Globals.player:
		
		var current_scene = get_tree().current_scene
		var first_node = current_scene.get_child(0)
		
		if not (current_scene.get_path() as String).to_lower().contains("lobby"):
			(first_node as Node2D).add_sibling.call_deferred(Globals.player)
			Globals.player.global_position = marker_2d.global_position
		
func _on_interactable_interact(_body:Node2D) -> void:
	Globals.next_scence_path = target_scene_path
	Globals.previous_scence_path = get_tree().current_scene.scene_file_path
	
	Globals.player.get_parent().remove_child(Globals.player)		
	get_tree().change_scene_to_packed(Globals.loading_screen)
