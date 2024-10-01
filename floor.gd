extends TileMapLayer

class_name Floor

const WALL_TILE_COORD = Vector2i(0, 0)
const FLOOR_TILE_COORD = Vector2i(1, 0)
const TILE_SIZE = 16
const CELL_SIZE = Vector2(TILE_SIZE, TILE_SIZE)

@onready var debug_line : Line2D = $"../DebugLine2D"

var astar_grid = AStarGrid2D.new()
var path: PackedVector2Array

func _ready() -> void:
	# Set up parameters, then update the grid.
	astar_grid.region = get_used_rect()
	astar_grid.cell_size = Vector2(TILE_SIZE, TILE_SIZE)
	astar_grid.offset = CELL_SIZE / 2
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()

	hide_points()
	
func hide_points() -> void:
	
	var all_tile_map_layer = []
	get_all_nodes_of_type(get_tree().root, "TileMapLayer", all_tile_map_layer)
	
	for layer: TileMapLayer in all_tile_map_layer:
		if layer.name == "Floor": continue
		for cell in layer.get_used_cells():
			astar_grid.set_point_solid(cell, true)
	
	#var all_static_bodies = []
	#get_all_nodes_of_type(get_tree().root, "StaticBody2D", all_static_bodies)
	#for static_body:StaticBody2D in all_static_bodies:
		#var point = astar_grid.get_closest_point(static_body.global_position)
		#astar_grid.set_point_solid(point, true)

## Recalculates the path between the two target nodes.
func recalculate_path(start: Node2D, end: Node2D) -> PackedVector2Array:
	path = astar_grid.get_point_path(local_to_map(start.global_position), local_to_map(end.global_position))
	debug_line.points = path
	return path
	
func recalculate_path2(start: Node2D, end: Node2D) -> PackedVector2Array:
	var path_ids = astar_grid.get_id_path(local_to_map(start.global_position), local_to_map(end.global_position))
	
	if path_ids.size() > 0:
		# Convert point IDs to positions
		path = []
		for id in path_ids:
			path.append(astar_grid.get_point_position(id))
		
	debug_line.points = path
	return path
	

func get_all_nodes_of_type(node: Node, type: String, result: Array) -> void:
	if node.is_class(type):
		result.append(node)
	for child in node.get_children():
		get_all_nodes_of_type(child, type, result)
		
