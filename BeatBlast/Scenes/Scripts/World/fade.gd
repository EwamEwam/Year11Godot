extends Node2D

@onready var screen = $BlackScreen
@onready var key = get_tree().get_first_node_in_group("Key")

@onready var notes_text = $Text

func _ready() -> void:
	if key != null:
		key.level_complete.connect(level_complete)
		key.game_complete.connect(game_complete)
	notes_text.visible = false

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

func game_complete():
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
	await get_tree().create_timer(2.5).timeout
	$Text.text = "Thank you so much for playing my game!"
	$Text.modulate.a = 0
	$Text.visible = true
	for i in range(20):
		await get_tree().create_timer(0.05).timeout
		$Text.modulate.a += 0.05
	await get_tree().create_timer(3).timeout
	for i in range(20):
		await get_tree().create_timer(0.05).timeout
		$Text.modulate.a -= 0.05
	get_tree().change_scene_to_file("res://Scenes/levels/results.tscn")

func fade_out(val, amt, time):
	screen.modulate = Color(0.004, 0, 0.041)
	await get_tree().create_timer(time).timeout
	screen.modulate.a = 1
	for i in range(amt):
		await get_tree().create_timer(0.05).timeout
		screen.modulate.a -= val
	get_tree().paused = false

func intro():
	screen.modulate = Color(0.004, 0, 0.041,1)
	var text = 0
	for i in range(3):
		text += 1
		await get_tree().create_timer(1).timeout
		notes_text.text = TextData.notes[str(text)]
		notes_text.visible = true
		notes_text.modulate.a = 0
		
		for d in range(20):
			await get_tree().create_timer(0.05).timeout
			notes_text.modulate.a += 0.05
			
		await get_tree().create_timer(5).timeout
		
		for d in range(20):
			await get_tree().create_timer(0.05).timeout
			notes_text.modulate.a -= 0.05
		
	await get_tree().create_timer(1).timeout
	for i in range(20):
		await get_tree().create_timer(0.05).timeout
		screen.modulate.a -= 0.05
	get_tree().paused = false

func Play():
	screen.modulate = Color(0.004, 0, 0.041)
	screen.modulate.a = 0
	for i in range(20):
		await get_tree().create_timer(0.05).timeout
		screen.modulate.a += 0.05
	var text = 3
	for i in range(2):
		text += 1
		await get_tree().create_timer(1).timeout
		notes_text.text = TextData.notes[str(text)]
		notes_text.visible = true
		notes_text.modulate.a = 0
		
		for d in range(20):
			await get_tree().create_timer(0.05).timeout
			notes_text.modulate.a += 0.05
			
		await get_tree().create_timer(5).timeout
		
		for d in range(20):
			await get_tree().create_timer(0.05).timeout
			notes_text.modulate.a -= 0.05
	
	get_tree().change_scene_to_file("res://Scenes/levels/level1.tscn")
