extends AnimatedSprite2D
#Just the collide animaiton for the player's bullet. When the animation is finished, it's queued for deletion
func _on_animation_finished():
	queue_free()
