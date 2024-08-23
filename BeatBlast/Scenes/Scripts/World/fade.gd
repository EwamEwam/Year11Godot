extends Node2D

@onready var screen = $BlackScreen
@onready var key = get_tree().get_first_node_in_group("Key")

func _ready() -> void:
	if key != null:
		key.level_complete.connect(level_complete)

func fade_in(val, amt, scene):
	screen.modulate = Color(0.004, 0, 0.041)
	screen.modulate.a = 0
	for i in range(amt):
		await get_tree().create_timer(0.05).timeout
		screen.modulate.a += val
	get_tree().change_scene_to_file(scene)
		
func level_complete():
	screen.modulate = Color(1,1,1,0)
	get_tree().paused = true
	for i in range(5):
		await get_tree().create_timer(0.05).timeout
		screen.modulate.a += 0.2
	await get_tree().create_timer(1).timeout
	for i in range(25):
		await get_tree().create_timer(0.05).timeout
		screen.modulate.r -= 0.04
		screen.modulate.g -= 0.04
		screen.modulate.b -= 0.04
	get_tree().change_scene_to_file("res://Scenes/levels/results.tscn")

func fade_out(val, amt, time):
	screen.modulate = Color(0.004, 0, 0.041)
	await get_tree().create_timer(time).timeout
	screen.modulate.a = 1
	for i in range(amt):
		await get_tree().create_timer(0.05).timeout
		screen.modulate.a -= val
	get_tree().paused = false
