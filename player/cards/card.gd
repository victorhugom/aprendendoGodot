class_name Card extends Panel

const PROJECTILE = preload("res://player/projectile.tscn")

signal destroyed

@onready var card_background_sprite: TextureRect = $PanelContainer/CardBackgroundSprite
@onready var card_name_label: RichTextLabel = $PanelContainer/CenterContainer/VBoxContainer/CardNameLabel
@onready var usages_remaining_label: RichTextLabel = $PanelContainer/CenterContainer/VBoxContainer/CenterContainer/UsagesRemainingLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var h_box_container: HFlowContainer = $PanelContainer/HBoxContainer


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

var transformation_backgrounds = {
	Enums.TransformationsENUM.SAUSAGE: preload("res://assets/cards/especial/specialcardbg.png")
}

var transformation_icons = {
	Enums.TransformationsENUM.SAUSAGE: preload("res://assets/cards/especial/transformationicon.png")
}

const NEUTRAL_BKG = preload("res://assets/cards/neutral/neutralcardbg.png")
const HPICON = preload("res://assets/cards/neutral/hpicon.png")

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
		create_projectile_card()
	elif card_config.CardType == Enums.CARD_TYPE.Transform:
		create_transformation_card()
	elif card_config.CardType == Enums.CARD_TYPE.Life:
		create_life_card()
	
	current_usage = card_config.MaxCardUsage

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func create_projectile_card() -> void:
	var card_projectile = card_config.CardData as CardDataProjectile	
		
	card_background_sprite.texture = card_backgrounds[card_projectile.ProjectileConfig.Element]
	#card_icon_sprite.texture = card_shoot_icons[card_projectile.ProjectileConfig.Element]
	card_name_label.text = card_config.Name
	
	for i in range(0, card_projectile.DPS):
		
		var new_icon_sprite = TextureRect.new()
		new_icon_sprite.texture = card_shoot_icons[card_projectile.ProjectileConfig.Element]
		new_icon_sprite.scale = Vector2(1/card_projectile.DPS, 1/card_projectile.DPS)
		h_box_container.add_child(new_icon_sprite)
		
func create_transformation_card() -> void:
	var card_transformation = card_config.CardData as CardDataTransformation	
		
	card_background_sprite.texture = transformation_backgrounds[card_transformation.TransformationEnum]
	card_name_label.text = card_config.Name
	
	var new_icon_sprite = TextureRect.new()
	new_icon_sprite.texture = transformation_icons[card_transformation.TransformationEnum]
	h_box_container.add_child(new_icon_sprite)	

func create_life_card() -> void:
	
	var card_transformation = card_config.CardData as CardDataHealth	
		
	card_background_sprite.texture = NEUTRAL_BKG
	card_name_label.text = card_config.Name
	
	var new_icon_sprite = TextureRect.new()
	new_icon_sprite.texture = HPICON
	h_box_container.add_child(new_icon_sprite)	

func execute_card() -> void:
	
	if card_config.CardType == Enums.CARD_TYPE.Projectile:
		execure_projectile()
	if card_config.CardType == Enums.CARD_TYPE.Life  && player.health < player.max_health:	
		execute_life_recover()
	if card_config.CardType == Enums.CARD_TYPE.Transform:	
		execute_transformation()

func execure_projectile() -> void:
	player.projectile_config = card_config.CardData.ProjectileConfig
	player.dps = card_config.CardData.DPS
	
func execute_life_recover() -> void:
	player.recover_life((card_config.CardData as CardDataHealth).Health)

func execute_transformation() -> void:
	player.transform(card_config)

func destroy_card() -> void:
	animation_player.play("destroy")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "destroy":
		destroyed.emit(self)
