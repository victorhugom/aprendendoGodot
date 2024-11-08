extends Node

var current_scene = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func get_all_nodes_of_type(root: Node, type: String) -> Array:
	# get all nodes of a godot type	
	
	var nodes = []	
	for child in root.get_children():
		if child.is_class(type):
			nodes.append(child)
		nodes += get_all_nodes_of_type(child, type)
	return nodes
	
func get_all_nodes_of_subtype(root: Node, type: Variant) -> Array:
	# get all nodes of a user created type
	
	var nodes = []	
	
	for child in root.get_children():
		if child.get_script() == type:
			nodes.append(child)
		nodes += get_all_nodes_of_subtype(child, type)
	return nodes
