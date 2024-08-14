extends Node2D

func _ready():
	get_tree().paused = false
	Playerstats.health = Playerstats.max_health
	Playerstats.score = 0

func _on_level_1_select_pressed():
	get_tree().change_scene_to_file("res://Scenes/levels/level.tscn")
