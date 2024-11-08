class_name WalkableTileMapLayer extends TileMapLayer

@export var not_walkable_tiles: Array[TileMapLayer]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	
	for tile_map in not_walkable_tiles:
		if coords in tile_map.get_used_cells():
			return true
			
	return false
	
func _tile_data_runtime_update(_coords: Vector2i, tile_data: TileData) -> void:
	tile_data.set_navigation_polygon(0, null)
