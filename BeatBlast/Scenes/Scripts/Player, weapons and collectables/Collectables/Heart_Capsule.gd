extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		Playerstats.max_health += 10
		body.heal(10)
		queue_free()
		
	match Playerstats.level:
		1:
			Playerstats.items_collected.Level1Heart = 1
		2:
			Playerstats.items_collected.Level2Heart = 1
		3:
			Playerstats.items_collected.Level3Heart = 1
		4:
			Playerstats.items_collected.Level4Heart = 1
		5:
			Playerstats.items_collected.Level5Heart = 1
