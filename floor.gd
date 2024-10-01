extends TileMapLayer

@onready var _sibling_layers = [$"../Walls",$"../Furniture", $"../Decoration"]

const WALL_TILE_COORD = Vector2i(0,0)
const TILE_SIZE = 16

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return _is_used_by_other_tile_map(coords)

func _is_used_by_other_tile_map(coords: Vector2i) -> bool:
	for sib in _sibling_layers:
		if coords in sib.get_used_cells():
			var collision_polygons_count = sib.get_cell_tile_data(coords).get_collision_polygons_count(0)
			if collision_polygons_count > 0:
				return true
	return false

func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	if _is_used_by_other_tile_map(coords):
		tile_data.set_navigation_polygon(0, null)
