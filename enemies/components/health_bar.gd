extends HBoxContainer

@export var health: Health:
	set(value):
		health = value
		health.health_changed.connect(update_hearts)
		set_max_hearts(health.max_health)
		update_hearts(health.current_health)
	get:
		return health
		
const HEALTH_UNIT = preload("res://enemies/components/health_unit.tscn")
var max_health = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_max_hearts(value: int = 3):
	
	var hearts = get_children()
	for h in hearts:
		remove_child(h)
	
	max_health = value
	@warning_ignore("integer_division")
	for i in range(0, max_health):
		var heart = HEALTH_UNIT.instantiate()
		add_child(heart)
		
func update_hearts(current_health: int):
	
	if current_health < max_health:
		visible = true
	else:
		visible = false
	
	var hearts = get_children()
	for i in range(0, current_health - 1):
		hearts[i].update(true)
	
	for i in range(current_health, hearts.size()):
		hearts[i].update(false);
