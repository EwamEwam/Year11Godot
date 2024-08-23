extends Node2D

var timer = 400
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var screen = $Level_elements/Player/Fade
@onready var key = get_tree().get_first_node_in_group("Key")
@onready var lighting = $Level_elements/Lighting
@onready var capsule = $Level_elements/Props/Heart_capsule

func _ready() -> void:
	Playerstats.enemies_defeated = 0
	Playerstats.bullets_shot = 0
	Playerstats.bullets_hit = 0
	lighting.modulate.a = 1
	timer = 400
	screen.fade_out(0.1,10,2.5)
	get_tree().paused = false
	player.died.connect(death)
	key.level_complete.connect(lights_out)
	if Playerstats.items_collected.Level1Heart == 1:
		capsule.queue_free()
	
func _on_timer_timeout():
	if timer > 0 and Playerstats.health > 0 and not get_tree().paused: 
		timer -= 1
	elif not get_tree().paused:
		Playerstats.health = 0

func death():
	get_tree().paused = true
	await get_tree().create_timer(3).timeout
	screen.fade_in(0.04,25,"res://Scenes/levels/results.tscn")
	
func lights_out():
	Playerstats.time_left = timer
	for i in range(5):
		lighting.modulate.a -= 0.2
	lighting.visible = false
