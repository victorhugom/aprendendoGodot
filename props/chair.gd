class_name Chair extends Area2D

@onready var marker_2d: Marker2D = $Marker2D

var is_empty: bool = true
var customer: Customer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is Customer and !customer:
		customer = body
		customer.global_position = marker_2d.global_position
		customer.is_sitting = true
