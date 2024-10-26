class_name Floor extends TileMapLayer

const WALL_TILE_COORD = Vector2i(0, 0)
const FLOOR_TILE_COORD = Vector2i(1, 0)
const TILE_SIZE = 32
const CELL_SIZE = Vector2(TILE_SIZE, TILE_SIZE)

#@onready var debug_line : Line2D = $"../DebugLine2D"

var astar_grid = AStarGrid2D.new()
var path: PackedVector2Array

func _ready() -> void:
	# Set up parameters, then update the grid.
	astar_grid.region = get_used_rect()
	astar_grid.cell_size = Vector2(TILE_SIZE, TILE_SIZE)
	astar_grid.offset = CELL_SIZE / 2
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()

	_disable_points()

func _disable_points() -> void:
	#set points that cannot be walked as solid
	
	var all_tile_map_layer = []
	all_tile_map_layer = Helper.get_all_nodes_of_type(get_tree().root, "TileMapLayer")
	
	for layer: TileMapLayer in all_tile_map_layer:
		if layer.name == "Floor": continue
		for cell in layer.get_used_cells():
			astar_grid.set_point_solid(cell, true)

func get_points_in_radius(center: Vector2, radius: float):
	
	var points_in_radius = []
	
	var region = astar_grid.region
	for x in range(region.position.x, region.position.x + region.size.x):
		for y in range(region.position.y, region.position.y + region.size.y):
			var point_id = Vector2i(x, y)
			if astar_grid.is_point_solid(point_id) == false:
				var point_position = astar_grid.get_point_position(point_id)
				if center.distance_to(point_position) <= radius:
					points_in_radius.append(point_position)

	if points_in_radius.size() > 0:
		var random_id = randi_range(0, points_in_radius.size() -1)
		return points_in_radius[random_id]
		
	return null

# Recalculates the path between the two target nodes.
func recalculate_path(start: Vector2, end: Vector2) -> PackedVector2Array:
	path = astar_grid.get_point_path(local_to_map(start), local_to_map(end), true)
	#debug_line.points = path
	return path
