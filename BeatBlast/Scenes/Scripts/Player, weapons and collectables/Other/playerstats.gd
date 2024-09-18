extends Node

#All variables that must be accessed in mutilple scenes are put here for ease of access.
var health = 90
var max_health = 90
var weapon_selected = 1
var weapons_unlocked = 5
var healing_item_selected = 1
var level = 1
var levels_unlocked = 1
var gems = 0
var player_x = 0
var player_y = 0
var score = 0
var gemsval = 0
var damval = 0
var dampval = 0
var scorenum = 0
var healnum = 0
var defence = 3
var attack = 3
var bullets_shot = 0
var bullets_hit = 0
var cooldown = 0
var door_open = 0
var healing_cooldown = 0

var blueprints = 0

#Settings for the player. Changes the games visuals, audio and other aspects of gameplay:
var settings = {
"Allow_Shaking" = true,
}

#Dictionary, used to track what collectables the player has collected in each level
var items_collected = {
"Level1Heart" = 0,
"Level1Blueprint" = 0,
"Level2Heart" = 0,
"Level2Blueprint" = 0
}

#Another dictionary for tracking the player's high score in each level.
var high_scores = {
"Level1HighScore" = 0,
"Level2HighScore" = 0
}

#Timers for each status effect that the player can get, it's 0 if the player doesn't have the effect.
var current_status = {
"Poison" = 0,
"Blocked" = 0,
"Slimed" = 0,
"Burning" = 0,
"Super_Poison" = 0
}

#Another dictionary used to store the current inventory. pickled hearts restore 20 hp, heart_salad restore 50 hp, heart_essence restores 100 hp
var healing_items = {
"Jar_of_pickled_hearts" = 1,
"Dried_hearts_in_a_can" = 1,
"Heart_essence" = 1
}

#Stores total stats for the player
var stats = {
"Bullets_shot" = 0,
"Bullets_hit" = 0,
"Enemies_defeated" = 0,
"Total_score" = 0,
"Play_time" = 0
}

var time_left = 0
var enemies_defeated = 0

var can_do = false

#Stores the store information like the level of each stat and the price of each item
var health_cost = 400
var health_lv = 0
var defence_cost = 750
var defence_lv = 0
var attack_cost = 1000
var attack_lv = 0

	
func _process(delta):
	if not can_do:
		can_do = true
		await get_tree().create_timer(1).timeout
		update_status()
		can_do = false
		
#Runs every second and manages the status effects and other cooldowns
func update_status():
	stats.Play_time += 1
	clampi(stats.Play_time,0,3599)
	gems = int(gems)
	var player = get_tree().get_first_node_in_group("Player")
	if player != null:
		if current_status.Poison > 0:
			player.damage_player(1)
			current_status.Poison -= 1
		if current_status.Blocked > 0:
			current_status.Blocked -= 1
		if current_status.Super_Poison > 0:
			player.damage_player(2)
			current_status.Super_Poison -= 1
		if current_status.Burning > 0:
			player.damage_player(1)
			current_status.Burning -= 1
		if current_status.Slimed > 0:
			current_status.Slimed -= 1
	if healing_cooldown > 0:
		healing_cooldown -= 1
