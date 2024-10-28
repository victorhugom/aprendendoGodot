class_name Card extends Panel

const PROJECTILE = preload("res://player/projectile.tscn")

signal destroyed

@onready var card_background_sprite: Sprite2D = $PanelContainer/CardBackgroundSprite
@onready var card_icon_sprite: Sprite2D = $PanelContainer/CardIconSprite
@onready var card_name_label: RichTextLabel = $PanelContainer/CenterContainer/VBoxContainer/CardNameLabel
@onready var usages_remaining_label: RichTextLabel = $PanelContainer/CenterContainer/VBoxContainer/CenterContainer/UsagesRemainingLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer


@export var card_config: CardConfig
@export var player: Player
@export var id: int


var card_backgrounds = {
	Enums.ELEMENTS.Neutral: preload("res://assets/cards/neutral/neutralcardbg.png"),
	Enums.ELEMENTS.Air: preload("res://assets/cards/air/aircardbg.png"),
	Enums.ELEMENTS.Water: preload("res://assets/cards/water/watercardbg.png"),
	Enums.ELEMENTS.Earth: preload("res://assets/cards/earth/earthcardbg.png"),
	Enums.ELEMENTS.Fire: preload("res://assets/cards/fire/firecardbg.png"),
}

var card_shoot_icons = {
	Enums.ELEMENTS.Neutral: preload("res://assets/cards/neutral/neutralshooticon.png"),
	Enums.ELEMENTS.Air: preload("res://assets/cards/air/airshooticon.png"),
	Enums.ELEMENTS.Water: preload("res://assets/cards/water/watershooticon.png"),
	Enums.ELEMENTS.Earth: preload("res://assets/cards/earth/earthshooticon.png"),
	Enums.ELEMENTS.Fire: preload("res://assets/cards/fire/fireshooticon.png"),
}

var current_usage: int:
	get:
		return current_usage
	set(value):
		current_usage = value
		
		if current_usage > 999:
			usages_remaining_label.text = "#"
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
	
	if card_config.CardType == Enums.CARD_TYPE.Projectile:
		var card_projectile = card_config.CardData as CardDataProjectile	
		
		card_background_sprite.texture = card_backgrounds[card_projectile.ProjectileConfig.Element]
		card_icon_sprite.texture = card_shoot_icons[card_projectile.ProjectileConfig.Element]
		card_name_label.text = card_config.Name
	
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
