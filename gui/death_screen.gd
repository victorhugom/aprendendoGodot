extends CanvasLayer

const LOADING_SCREEN = preload("res://gui/loadingScreen.tscn")
var loading_screen: LoadingScreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_restart_button_pressed() -> void:
	loading_screen = LOADING_SCREEN.instantiate()
	Globals.next_scence_path = "res://levels/lobby.tscn"
	get_tree().change_scene_to_packed(Globals.loading_screen)
	queue_free()
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()
