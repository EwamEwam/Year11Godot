extends Node2D

var timer = 400
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var screen = $Level_elements/Player/Fade

func _ready() -> void:
	screen.fade_out(0.1,10,2.5)
	get_tree().paused = false
	player.died.connect(death)

func _on_timer_timeout():
	if timer > 0 and Playerstats.health > 0: 
		timer -= 1
	else:
		Playerstats.health = 0

func death():
	get_tree().paused = true
	await get_tree().create_timer(3).timeout
	screen.fade_in(0.04,25,"res://Scenes/levels/results.tscn")
