extends Area2D
#The Blueprint Collectable. When collected, sets a value in the items collected dictionary.
@export var id = 0

signal level_complete

func _on_body_entered(body):
	if body.is_in_group("Player"):
		Playerstats.blueprints += 1
		queue_free()
		match Playerstats.level:
			1:
				Playerstats.items_collected.Level1Blueprint = 1
			2:
				Playerstats.items_collected.Level2Blueprint = 1
			3:
				Playerstats.items_collected.Level3Blueprint = 1
