extends Card

@onready var card_item_animation_player: AnimationPlayer = $CardItemAnimationPlayer

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		card_item_animation_player.play("dismiss")
		player = body
		

func _on_card_item_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "dismiss":
		get_parent().remove_child(self)
		Hud.card_hand.add_card(self, player)
		card_item_animation_player.play("RESET")
