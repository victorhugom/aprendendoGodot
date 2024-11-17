class_name Interactable extends Area2D

signal interact(body: Node2D)
signal begin_focus(body: Node2D)
signal end_focus(body: Node2D)

@export var interact_message:= "Interagir"
@export var cannot_interact_message:= "Não pode interagir"
@export var can_interact_once:= false
@export var disabled := false

@export_category("Requires Key")
@export var requires_item:=false
@export var required_item_type: Enums.ITEM_TYPE
@export var required_item_quantity:= 1

var in_interaction_area:= false
var interactor: Node2D

func _on_body_entered(body: Node2D) -> void:
	interactor = body
	
	if can_interact():
		InteractionCall.show_interaction(interact_message)
	else:
		InteractionCall.show_interaction(cannot_interact_message)
	
	print_debug("Body Entered %s:" %body)
	in_interaction_area = true
	begin_focus.emit(body)

func _on_body_exited(body: Node2D) -> void:
	interactor = null
	
	InteractionCall.hide_interaction()
	
	print_debug("Body Exit %s:" %body)
	in_interaction_area = false
	end_focus.emit(body)
	
func _input(event):
	if interactor and event.is_action_pressed("ui_interact") and can_interact():
		interact.emit(interactor)
		if can_interact_once:
			disabled = true  # Desabilita interação após a primeira interação
		InteractionCall.hide_interaction()  # Esconde a mensagem de interação
		
func can_interact() -> bool:
	
	if disabled:
		return false
	
	if requires_item == false:
		return true
	
	var inventory = interactor.get_node("Inventory") as Inventory
	assert(inventory != null, "Error: Inventory not found, check if inventory is in the actor, is in the root and with the name 'Inventory' case sensitive")
	
	var required_item = inventory.has_item(required_item_type)
	
	return required_item.size() > 0 && required_item.size() >= required_item_quantity
