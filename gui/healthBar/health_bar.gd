class_name HealthBar extends HBoxContainer

@export var health: Health:
	set(value):
		health = value
		if health.health_changed.get_connections().size() > 0:
			health.health_changed.disconnect(health.health_changed.get_connections()[0])
		health.health_changed.connect(update_hearts)
		set_max_hearts(health.max_health)
		update_hearts(health.current_health)
	get:
		return health

const HEART = preload("res://gui/healthBar/heart.tscn")
var max_health = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_max_hearts(value: int = 3, transformation = false):
	
	var hearts = get_children()
	for h in hearts:
		remove_child(h)
	
	max_health = value
	@warning_ignore("integer_division")
	for i in range(0, max_health/3): # on full hearth for each 3 hearts
		var heart = HEART.instantiate()
		if transformation:
			heart.set_texture(preload("res://assets/heart_transformation.png"))
			
		add_child(heart)
		
func update_hearts(current_health: int):

	var hearts = get_children()
	
	var small_hearts = current_health % 3
	@warning_ignore("integer_division")
	var full_hearts = (current_health - small_hearts)/3
	
	for i in range(full_hearts):
		hearts[i].update(true)
	
	if small_hearts != 0:
		hearts[full_hearts].update(false, small_hearts)
	
	for i in range(full_hearts + 1, hearts.size()):
		hearts[i].update(false);
