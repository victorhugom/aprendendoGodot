class_name PauseScreen extends CanvasLayer

@onready var items_container: VBoxContainer = $CenterContainer/ItemsContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event.is_action_released("ui_pause"):
		get_tree().paused = false
		queue_free()

func _on_restart_button_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().change_scene_to_file("res://main.tscn")