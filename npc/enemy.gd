class_name Enemy extends "res://npc/npc.gd"

@onready var animation_player: AnimationPlayer = $Enemy/AnimationPlayer
@onready var enemy: Sprite2D = $Enemy

var life = 3
var is_being_hit = false
var is_dying = false

func _ready() -> void:
	super._ready()
	track_node(%Player)
	
func _physics_process(delta: float) -> void:
	
	if is_dying || is_being_hit: 
		return
	
	super._physics_process(delta)
	
	if velocity.x < 0:
		enemy.flip_h = false
	else:
		enemy.flip_h = true
		
	if is_being_hit: return
	
	if velocity.x != 0:
		animation_player.play("walk_left")
	else:
		animation_player.play("idle_left")
	
	
func damage(hurt_points: int, damage_type: Enums.ELEMENTS) -> void:
	
	if is_dying || is_being_hit: return
	
	life -= hurt_points
	
	if life <= 0:
		is_dying = true
		animation_player.play("death")
	else:
		is_being_hit = true
		animation_player.play("hit")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hit":
		is_being_hit = false
	if anim_name == "death":
		queue_free()

	
	
