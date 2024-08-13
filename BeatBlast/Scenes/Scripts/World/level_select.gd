extends Node2D

@onready var level_1_button = $level_1_select

func _on_level_1_select_pressed():
	get_tree().change_scene_to_file("res://Scenes/levels/level.tscn")
