extends Area2D

@export var id = 0

signal level_complete
signal game_complete

func _on_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("level_complete")
		queue_free()
