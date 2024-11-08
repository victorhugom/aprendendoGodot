extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_restart_button_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().change_scene_to_file("res://levels/main.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()
