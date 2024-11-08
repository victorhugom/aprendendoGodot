class_name Card extends Panel

const PROJECTILE = preload("res://player/projectile.tscn")

signal destroyed

@onready var card_background_sprite: TextureRect = $PanelContainer/CardBackgroundSprite
@onready var card_name_label: RichTextLabel = $PanelContainer/CenterContainer/VBoxContainer/CardNameLabel
@onready var usages_remaining_label: RichTextLabel = $PanelContainer/CenterContainer/VBoxContainer/CenterContainer/UsagesRemainingLabel
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var keyboard_shortcut: TextureRect = $PanelContainer/KeyboardShortcut

@onready var card_icons_container: HFlowContainer = $PanelContainer/CardIconsContainer

@export var card_config: CardConfig
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

var shortcut_id: int:
	get:
		return shortcut_id
	set(value):
		shortcut_id = value
			
		if shortcut_id != 0:
			keyboard_shortcut.texture = load("res://assets/external_resources/kenney_input-prompts/Keyboard & Mouse/Double/keyboard_%s.png" %shortcut_id)
			keyboard_shortcut.visible = true
		else:
			keyboard_shortcut.visible = false

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
		
	card_background_sprite.texture = card_backgrounds[card_projectile.projectile_config.element]
	card_name_label.text = card_config.Name
	
	var card_icon_size = Vector2(64, 64)

	if card_projectile.DPS == 2:
		card_icon_size = Vector2(30, 30)
	elif card_projectile.DPS == 3:
		card_icon_size = Vector2(20, 20)
	elif card_projectile.DPS == 4:
		card_icon_size = Vector2(20, 20)
	
	for i in range(0, card_projectile.DPS):
		var card_icon = TextureRect.new()
		card_icon.size = card_icon_size
		card_icon.custom_minimum_size = card_icon_size
		card_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		card_icon.stretch_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		card_icon.texture = card_shoot_icons[card_projectile.projectile_config.element]
		card_icons_container.add_child(card_icon)

func create_transformation_card() -> void:
	var card_transformation = card_config.CardData as CardDataTransformation	
		
	card_background_sprite.texture = transformation_backgrounds[card_transformation.transformationEnum]
	card_name_label.text = card_config.Name
	
	var card_icon = TextureRect.new()
	card_icon.size = Vector2(64, 64)
	card_icon.texture = transformation_icons[card_transformation.transformationEnum]
	card_icons_container.add_child(card_icon)	

func create_life_card() -> void:
	
	card_background_sprite.texture = NEUTRAL_BKG
	card_name_label.text = card_config.Name
	
	var card_icon = TextureRect.new()
	card_icon.size = Vector2(64, 64)
	card_icon.texture = HPICON
	card_icons_container.add_child(card_icon)

func destroy_card() -> void:
	animation_player.play("destroy")
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "destroy":
		destroyed.emit(self)
