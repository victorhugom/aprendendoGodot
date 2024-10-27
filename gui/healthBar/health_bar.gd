class_name HealthBar extends HBoxContainer

const HEART = preload("res://gui/healthBar/heart.tscn")
var max_health = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func setMaxHearts(health: int = 3, transformation = false):
	
	var hearts = get_children()
	for h in hearts:
		remove_child(h)
	
	max_health = health
	for i in range(max_health):
		var heart = HEART.instantiate()
		if transformation:
			heart.set_texture(preload("res://assets/heart_transformation.png"))
			
		add_child(heart)
		
func updateHeats(currentHealth: int):
	var hearts = get_children()
	for i in range(currentHealth):
		hearts[i].update(true)
		
	for i in range(currentHealth, hearts.size()):
		hearts[i].update(false);
				
