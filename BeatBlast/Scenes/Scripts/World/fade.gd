extends Node2D

@onready var screen = $BlackScreen

func fade_in(val, amt, scene):
	screen.modulate.a = 0
	for i in range(amt):
		await get_tree().create_timer(0.05).timeout
		screen.modulate.a += val
	get_tree().change_scene_to_file(scene)
		
func fade_out(val, amt, time):
	await get_tree().create_timer(time).timeout
	screen.modulate.a = 1
	for i in range(amt):
		await get_tree().create_timer(0.05).timeout
		screen.modulate.a -= val
