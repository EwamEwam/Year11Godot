extends Node2D

@onready var screen = $Fade
var button_pressed = false

func _ready():
	screen.fade_out(0.1 ,10, 0)
	button_pressed = false
	get_tree().paused = false
	Playerstats.health = Playerstats.max_health
	Playerstats.score = 0
	Playerstats.current_status.Poisoned = 0

func _on_level_1_select_pressed():
	if not button_pressed:
		screen.fade_in(0.1, 10, "res://Scenes/levels/level.tscn")
		get_tree().paused = true
		button_pressed = true

func _on_store_pressed():
	if not button_pressed:
		screen.fade_in(0.1,10, "res://Scenes/levels/store.tscn")
		get_tree().paused = true
		button_pressed = true
