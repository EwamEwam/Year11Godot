extends Node

var health = 30
var max_health = 30
var weapon_selected = 1
var weapons_unlocked = 4
var level = 1
var gems = 0
var gun_parts = 0
var player_x = 0
var player_y = 0
var score = 0
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
@onready var player = get_tree().get_first_node_in_group("Player")

signal reloaded

func _physics_process(delta):
	if health < 1:
		reload()
	
func reload():
	get_tree().paused = true
	await get_tree().create_timer(3).timeout
	get_tree().reload_current_scene()
	max_health = 30
	health = max_health
	score = 0
	weapon_selected = 1
	get_tree().paused = false
	await get_tree().create_timer(0.001).timeout
	emit_signal("reloaded")
