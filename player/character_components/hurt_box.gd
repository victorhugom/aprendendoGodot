class_name HurtBox extends Area2D

signal damaged

@export var health: Health
@export var can_be_hurt: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#TRACE HIT AREA ON PLAYER, cada frame do bracinho um frame de hut
func _on_area_entered(area: Area2D) -> void:
	
	if can_be_hurt == false:
		return
	
	if area is Projectile:
		var projectile = area as Projectile
		var damage = projectile.projectile_config.damage
		var damage_type = projectile.projectile_config.element
		
		print_debug("HurtBox: Projectile: Take Damage %s, %s" %[damage, damage_type] )
		health.decrease_health(damage)
		damaged.emit()
			
	if area is MeleeCollisionBox:
		var melee = area as MeleeCollisionBox
		var damage = melee.damage
		
		print_debug("HurtBox: Melee: Take Damage %s" %damage )
		health.decrease_health(damage)
		damaged.emit()
