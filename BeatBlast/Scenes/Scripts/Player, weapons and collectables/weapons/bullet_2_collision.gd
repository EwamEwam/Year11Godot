extends AnimatedSprite2D
#Same as the other bullet collide animation. There shouldn't be two of these.
func _on_animation_finished():
	queue_free()
