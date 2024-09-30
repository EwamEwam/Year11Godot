extends Area2D

@export var id = 0

signal game_complete
signal level_complete

func _on_body_entered(body):
	if body.is_in_group("Player"):
		emit_signal("game_complete")
		queue_free()
