class_name CardDataProjectile extends CardDataInterface

@export var DPS: int
## speed in which the projectile goes forward
@export var projectile_speed:= 36 * 5
## size of the projectile
@export var projectile_scale:= 1
## speed in which the shoot animation goes
@export var shoot_speed:= 1
## interval in wich each projectiles goes after the first
@export var shoot_interval: float = 0.1
@export var projectile_config: ProjectileConfig
