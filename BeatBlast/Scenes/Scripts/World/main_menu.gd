extends Node2D

var button_pressed = false
const particle = preload("res://Scenes/Other/Title_particles.tscn")

@onready var fade = $Fade

func _ready() -> void:
	reset_stats()
	fade.intro()
	button_pressed = true
	await get_tree().create_timer(19).timeout
	button_pressed = false

func _on_quit_pressed() -> void:
	if not button_pressed:
		button_pressed = true
		get_tree().quit()

func _on_particle_timer_timeout() -> void:
	var new_particle = particle.instantiate()
	new_particle.global_position.x = randi_range(0,1000)
	new_particle.global_position.y = 0
	add_child(new_particle)

func _on_play_pressed() -> void:
	if not button_pressed:
		button_pressed = true
		fade.Play()
		
#Resets all the player's stats and data back to default. This allows the player to replay the game, not that most people would want to in the same sitting.
func reset_stats() -> void:
	Playerstats.max_health = 30
	Playerstats.defence = 0
	Playerstats.attack = 0
	Playerstats.gems = 0
	Playerstats.weapons_unlocked = 2
	Playerstats.weapon_selected = 1
	Playerstats.levels_unlocked = 1
	Playerstats.blueprints = 0
	Playerstats.level = 1
	
	Playerstats.items_collected.Level1Heart = 0
	Playerstats.items_collected.Level1Blueprint = 0
	Playerstats.items_collected.Level2Heart = 0
	Playerstats.items_collected.Level2Blueprint = 0
	Playerstats.items_collected.Level3Heart = 0
	Playerstats.items_collected.Level3Blueprint = 0
	Playerstats.items_collected.Level4Heart = 0
	
	Playerstats.healing_items.Jar_of_pickled_hearts = 1
	Playerstats.healing_items.Dried_hearts_in_a_can = 0
	Playerstats.healing_items.Heart_essence = 0
	
	Playerstats.stats.Bullets_shot = 0
	Playerstats.stats.Bullets_hit = 0
	Playerstats.stats.Enemies_defeated = 0
	Playerstats.stats.Total_score = 0
	Playerstats.stats.Play_time = 0
	
	Playerstats.high_scores.Level1HighScore = 0
	Playerstats.high_scores.Level2HighScore = 0
	Playerstats.high_scores.Level3HighScore = 0
	Playerstats.high_scores.Level4HighScore = 0

	Playerstats.health_cost = 200
	Playerstats.health_lv = 0
	Playerstats.defence_cost = 350
	Playerstats.defence_lv = 0
	Playerstats.attack_cost = 550
	Playerstats.attack_lv = 0
