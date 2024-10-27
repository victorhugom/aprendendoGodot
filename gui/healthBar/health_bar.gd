class_name HealthBar extends HBoxContainer

const HEART = preload("res://gui/healthBar/heart.tscn")
var maxHealth = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func setMaxHearts(max: int = 3):
	maxHealth = max
	for i in range(max):
		var heart = HEART.instantiate()
		add_child(heart)
		
func updateHeats(currentHealth: int):
	var hearts = get_children()
	for i in range(currentHealth):
		hearts[i].update(true)
		
	for i in range(currentHealth, hearts.size()):
		hearts[i].update(false);
				
