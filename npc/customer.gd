extends CharacterBody2D

@export var player: CharacterBody2D
@export var movement_speed: float = 16*4
@onready var navigation_agent: NavigationAgent2D = get_node("NavigationAgent2D")

func _ready() -> void:
	var agent: RID = get_rid()
	# Enable avoidance
	NavigationServer2D.agent_set_avoidance_enabled(agent, true)

func _physics_process(delta):
	
	var player_position = player.global_position
	navigation_agent.set_target_position(player_position)

	# Do not query when the map has never synchronized and is empty.
	if NavigationServer2D.map_get_iteration_id(navigation_agent.get_navigation_map()) == 0:
		return
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var new_velocity: Vector2 = global_position.direction_to(next_path_position) * movement_speed
	if navigation_agent.avoidance_enabled:
		navigation_agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	move_and_slide()
	
