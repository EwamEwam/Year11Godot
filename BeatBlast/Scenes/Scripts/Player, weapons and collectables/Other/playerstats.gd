extends Node

#All variables that must be accessed in mutilple scenes are put here for ease of access.
var health = INF
var max_health = INF
var weapon_selected = 1
var weapons_unlocked = 5
var level = 1
var gems = 0
var gun_parts = 0
var player_x = 0
var player_y = 0
var score = 0
var gemsval = 0
var damval = 0
var dampval = 0
var scorenum = 0
var healnum = 0
var defence = 0
var bullets_shot = 0
var bullets_hit = 0
var accuracy = 0
var cooldown = 0
var door_open = 0

#Dictionary, used to track what collectables the player has collected in each level
var items_collected = {
"Level1Heart" = 0,
"Level1WeaponBlueprint" = 0,
"Level2Heart" = 0,
"Level2WeaponBlueprint" = 0
}

#Another dictionary for tracking the player's high score in each level.
var high_scores = {
"Level1HighScore" = 0,
"Level2HighScore" = 0
}

#Timers for each status effect that the player can get, it's 0 if the player doesn't have the effect.
var current_status = {
"Poison" = 0
}

var can_do = false
	
func _process(delta):
	if not can_do:
		can_do = true
		await get_tree().create_timer(1).timeout
		update_status()
		can_do = false
		
func update_status():
	var player = get_tree().get_first_node_in_group("Player")
	if current_status.Poison > 0:
		player.damage_player(1)
		current_status.Poison -= 1
