class_name Card extends Panel

const PROJECTILE = preload("res://player/projectile.tscn")

signal destroyed

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var usages_remaining_label: RichTextLabel = $Sprite2D/CenterContainer/UsagesRemainingLabel

@export var card_config: CardConfig
@export var player: Player
@export var id: int

var current_usage: int:
	get:
		return current_usage
	set(value):
		current_usage = value
		if value > 9999:
			usages_remaining_label.text = "/"
		else:
			usages_remaining_label.text = str(value)

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
	
	current_usage = card_config.MaxCardUsage

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func execute_card() -> void:
	
	if card_config.CardType == Enums.CARD_TYPE.Projectile:
		execure_projectile()
	if card_config.CardType == Enums.CARD_TYPE.Life:	
		execute_life_recover()
	if card_config.CardType == Enums.CARD_TYPE.Transform:	
		execute_transformation()

func execure_projectile() -> void:
	player.projectile_config = card_config.CardData.ProjectileConfig
	player.dps = card_config.CardData.DPS
	
func execute_life_recover() -> void:
	pass

func execute_transformation() -> void:
	player.transform(card_config)

func destroy_card() -> void:
	animation_player.play("destroy")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "destroy":
		destroyed.emit(self)
