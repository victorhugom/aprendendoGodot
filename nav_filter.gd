extends TileMapLayer

@onready var walls: TileMapLayer = $"../Walls"
@onready var furniture: TileMapLayer = $"../Furniture"
@onready var decoration: TileMapLayer = $"../Decoration"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	
	if coords in walls.get_used_cells() || coords in furniture.get_used_cells() ||  coords in decoration.get_used_cells():
		return true
		
	return false
	
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	tile_data.set_navigation_polygon(0, null)
