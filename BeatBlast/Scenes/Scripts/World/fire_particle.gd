extends Node2D

func _ready() -> void:
	global_position.y += randf_range(-20,20)
	global_position.x += randf_range(-20,20)
