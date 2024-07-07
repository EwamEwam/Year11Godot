extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		Playerstats.max_health += 10
		body.heal(10)
		queue_free()
