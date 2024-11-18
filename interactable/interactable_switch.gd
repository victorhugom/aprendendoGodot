@tool
class_name InteractableSwitch extends Sprite2D

signal interact(body: Node2D)

@export var animation_player: AnimationPlayer

@onready var interactable: Interactable = $Interactable
@onready var collision_shape: CollisionShape2D = $Interactable/CollisionShape2D

var current_state:= "state_a"

# Define custom properties for collision layers and masks
var collision_layers = 0 #setget set_collision_layers
var collision_masks = 0 #setget set_collision_masks

# Override _get_property_list to add custom properties to the editor
func _get_property_list() -> Array:
	var properties: Array = []
	properties.append({
		"name": "collision_layers",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_LAYERS_2D_PHYSICS,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	properties.append({
		"name": "collision_masks",
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_LAYERS_2D_PHYSICS,
		"usage": PROPERTY_USAGE_DEFAULT
	})
	return properties

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(interactable != null, "interactable not found")
	
	assert(animation_player != null, "animation player not found")
	assert(animation_player.has_animation("state_a"), "state_a not found, create it on animation player")
	assert(animation_player.has_animation("state_b"), "state_b not found, create it on animation player")
	
	interactable.interact.connect(_on_interactable_interacted)
	
	var texture_size = texture.get_size()
	var rect_shape = collision_shape.shape as RectangleShape2D 
	# Set the new size
	rect_shape.size = texture_size
	
	interactable.collision_layer = collision_layers  # Update the internal collision layer
	interactable.collision_mask = collision_masks  # Update the internal collision mask

func _on_interactable_interacted(body: Node2D) -> void:
	
	if current_state == "state_a":
		current_state = "state_b"
	else:
		current_state = "state_a"
	
	animation_player.play(current_state)
	interact.emit(body)
