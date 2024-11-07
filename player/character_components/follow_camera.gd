class_name FollowCamera extends Camera2D

@onready var camera: Camera2D = $"."
var ground_map_tile: TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_camera_limit():
	var map_limits = ground_map_tile.get_used_rect()
	var map_cellsize = 32
	var worldMapInPixels = map_limits.size * map_cellsize
	
	camera.limit_right = worldMapInPixels.x
	camera.limit_bottom = worldMapInPixels.y
