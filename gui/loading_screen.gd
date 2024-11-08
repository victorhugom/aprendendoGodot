class_name LoadingScreen extends CanvasLayer

@onready var loading_sprite: AnimatedSprite2D = $CenterContainer/LoadingSprite

var loading_status : int
var progress : Array[float]

func _ready() -> void:
	# Request to load the target scene:
	loading_sprite.play("default")
	
	var parent_size = loading_sprite.get_parent().get_rect().size 
	loading_sprite.position = parent_size / 2 - Vector2(128,128)
	
	ResourceLoader.load_threaded_request(Globals.next_scence_path)
	
func _process(_delta: float) -> void:
	# Update the status:
	loading_status = ResourceLoader.load_threaded_get_status(Globals.next_scence_path, progress)
	
	# Check the loading status:
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			print_debug("%s loading scene in bkg: %s" %[Time.get_time_string_from_system(), progress[0] * 100])
			#progress_bar.value = progress[0] * 100 # Change the ProgressBar value
		ResourceLoader.THREAD_LOAD_LOADED:
			# When done loading, change to the target scene:
			print_debug("%s: %s loaded scene in bkg" %[Time.get_time_string_from_system(), progress[0] * 100])
			var next_screen_packed = ResourceLoader.load_threaded_get(Globals.next_scence_path)
			get_tree().change_scene_to_packed(next_screen_packed)
			print_debug("%s: changed to scene" %Time.get_time_string_from_system())
			
		ResourceLoader.THREAD_LOAD_FAILED:
			# Well some error happend:
			print_debug("Error. Could not load Resource")
			
