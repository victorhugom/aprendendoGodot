class_name LandingScene extends CanvasLayer

const LOADING_SCREEN = preload("res://gui/loadingScreen.tscn")

var loading_screen: LoadingScreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loading_screen = LOADING_SCREEN.instantiate()
	pass # Replace with function body.

func _on_start_button_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	Globals.next_scence_path = "res://levels/main.tscn"
	get_tree().change_scene_to_packed(Globals.loading_screen)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
