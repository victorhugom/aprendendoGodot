class_name SavedGame extends Resource

const CARD_CONFIG_AIR_SHOOT = preload("res://cards/configs/card_config_air_shoot.tres")
const CARD_CONFIG_BASIC_SHOOT = preload("res://cards/configs/card_config_basic_shoot.tres")
const CARD_CONFIG_BASIC_SHOOT_DOUBLE = preload("res://cards/configs/card_config_basic_shoot_double.tres")
const CARD_CONFIG_EARTH_SHOOT = preload("res://cards/configs/card_config_earth_shoot.tres")
const CARD_CONFIG_FIRE_SHOOT = preload("res://cards/configs/card_config_fire_shoot.tres")
const CARD_CONFIG_HEALTH_POTION = preload("res://cards/configs/card_config_health_potion.tres")
const CARD_CONFIG_TRANSFORM_SAUSAGE = preload("res://cards/configs/card_config_transform_sausage.tres")
const CARD_CONFIG_WATER_SHOOT = preload("res://cards/configs/card_config_water_shoot.tres")

@export var max_health := 9
@export var deck_cards: Array[DeckCardItem]
@export var cards_owned : Array[CardConfig] = [
	 CARD_CONFIG_BASIC_SHOOT_DOUBLE,
	 CARD_CONFIG_AIR_SHOOT,
	 CARD_CONFIG_EARTH_SHOOT,
	 CARD_CONFIG_FIRE_SHOOT,
	 CARD_CONFIG_HEALTH_POTION,
	 CARD_CONFIG_TRANSFORM_SAUSAGE,
	 CARD_CONFIG_WATER_SHOOT,
]
