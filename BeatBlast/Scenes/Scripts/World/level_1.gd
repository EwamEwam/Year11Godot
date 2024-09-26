extends Node2D

#Declaring variables for various objects in the level like the player and the key.
var timer = 300
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var screen = $Level_elements/Player/Fade
@onready var key = get_tree().get_first_node_in_group("Key")
@onready var blueprint = $Level_elements/Props/Blueprint
@onready var lighting = $Level_elements/Lighting
@onready var capsule = $Level_elements/Props/Heart_capsule

@onready var hints = $Level_elements/Player/CanvasLayer/Tutorial_Animation
@onready var music = $Background_Music

const snow_particle = preload("res://Scenes/Other/Snow.tscn")

var hint_val = 0
var animation_started = false
var last_hint_played = 0

#Sets all the variables when a level starts, this includes timers and playerstats. Also deletes upgrades if they have already been collected
func _ready() -> void:
	hints.visible = false
	Playerstats.enemies_defeated = 0
	Playerstats.bullets_shot = 0
	Playerstats.bullets_hit = 0
	lighting.modulate.a = 1
	timer = 300
	screen.fade_out(0.1,10,2.5)
	get_tree().paused = false
	player.died.connect(death)
	key.level_complete.connect(lights_out)
	if Playerstats.items_collected.Level1Heart == 1:
		capsule.queue_free()
	if Playerstats.items_collected.Level1Blueprint == 1:
		blueprint.queue_free()
	await get_tree().create_timer(4).timeout
	hint_val += 1
	
func _process(delta: float) -> void:
	if last_hint_played < hint_val and not animation_started:
		tutorial_animation(last_hint_played + 1)
		animation_started = true
	if randi_range(0,4) == 0:
		create_particle()
	
	if Playerstats.sign_text.length() != 0:
		hide_text()
	else:
		show_text()
	
func _on_timer_timeout():
	if timer > 0 and Playerstats.health > 0 and not get_tree().paused: 
		timer -= 1
	elif not get_tree().paused:
		Playerstats.health = 0

func death():
	for i in range(20):
		music.volume_db -= linear_to_db(1.5) 
		await get_tree().create_timer(0.05).timeout
	music.stream_paused = true
	get_tree().paused = true
	await get_tree().create_timer(2).timeout
	screen.fade_in(0.04,25,"res://Scenes/levels/results.tscn")
	
func lights_out():
	Playerstats.time_left = timer
	for i in range(5):
		lighting.modulate.a -= 0.2
	lighting.visible = false
	
func tutorial_animation(type):
	hints.visible = true
	$Level_elements/Player/CanvasLayer/AnimationPlayer.play(str(type))
	await $Level_elements/Player/CanvasLayer/AnimationPlayer.animation_finished
	last_hint_played += 1
	animation_started = false

#Very Rudimentary way to get the trigger system to work. Makes signals for each triggers 
func _on_trigger_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and hint_val < 2:
		hint_val += 1

func _on_trigger_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and hint_val < 3:
		hint_val += 1

func _on_trigger_3_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and hint_val < 4:
		hint_val += 1

func _on_trigger_4_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and hint_val < 5:
		hint_val += 1

func _on_trigger_5_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and hint_val < 6:
		hint_val += 1

func _on_trigger_6_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and hint_val < 7:
		hint_val += 1

func _on_trigger_7_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and hint_val < 8:
		hint_val += 1

func create_particle():
	var new_particle = snow_particle.instantiate()
	new_particle.global_position.x = Playerstats.player_x - randi_range(-4000,4000)
	new_particle.global_position.y = Playerstats.player_y - 1250
	add_sibling(new_particle)

func hide_text():
	hints.visible = false
	
func show_text():
	hints.visible = true
