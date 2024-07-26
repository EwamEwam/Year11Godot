extends Node2D

var timer = 300

func _on_timer_timeout():
	if timer > 0:
		timer -= 1
	else:
		Playerstats.health = 0
