class_name Card extends Panel

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var card_config: CardConfig
@export var player: Player

@export var id: int
var in_use: bool:
	get:
		return in_use
	set(value):
		if value:
			animation_player.play("up")
		else:
			animation_player.play("down")
			
		in_use = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	id = ResourceUID.create_id()
	sprite_2d.texture = card_config.CardTexture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func execute_card() -> void:
	
	if card_config.CardType == Enums.CARD_TYPE.Projectile:
		execure_projectile()
	if card_config.CardType == Enums.CARD_TYPE.Life:	
		execute_life_recover()

func execure_projectile() -> void:
	player.projectile_config = card_config.CardData.Projectile
	player.dps = card_config.CardData.DPS
	
func execute_life_recover() -> void:
	pass
