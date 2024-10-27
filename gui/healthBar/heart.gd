extends Panel

@onready var sprite = $Sprite2D
var heart_texture: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if heart_texture:
		sprite.texture = heart_texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func set_texture(texture: Texture2D):
	heart_texture = texture
	
func update(full: bool):
	if full:
		sprite.frame = 3
	else:
		sprite.frame = 0
