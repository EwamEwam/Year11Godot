extends Node2D

@onready var heading = $Headings/Heading
@onready var score = $Score_val
@onready var time = $Time_left_val
@onready var enemies = $Enemies_val
@onready var shot = $Shot_val
@onready var hit = $Hit_val
@onready var accuracy = $Accuracy_val
@onready var time_bonus = $Bonus_val
@onready var accuracy_bonus = $Bonus_accu_val
@onready var life_bonus = $Bonus_life_val
@onready var gems = $Gem_Bonus_val
@onready var total_score = $Total_score_val
@onready var screen = $Fade

var accuracy_value
var time_bonus_value = 0
var accuracy_bonus_value = 0
var life_bonus_value = 0
var bonus_gems = 0
var total_score_value = 0

func _ready() -> void:
	if Playerstats.health > 0:
		heading.text = "RESULTS - SUCCESS"
	else:
		heading.text = "RESULTS - FAILURE"
	score.visible =false
	time.visible =false
	enemies.visible =false
	hit.visible =false
	shot.visible =false
	accuracy.visible =false
	time_bonus.visible =false
	accuracy_bonus.visible =false
	life_bonus.visible =false
	gems.visible = false
	total_score.visible =false
	screen.fade_out(0.05,20,1)
	get_tree().paused = false
	calculate_values()
	score.text = str(Playerstats.score)
	time.text = str(Playerstats.time_left)
	enemies.text = str(Playerstats.enemies_defeated)
	shot.text = str(Playerstats.bullets_shot)
	hit.text = str(Playerstats.bullets_hit)
	accuracy.text = str(accuracy_value) + "%"
	time_bonus.text = str(time_bonus_value)
	accuracy_bonus.text = str(accuracy_bonus_value)
	life_bonus.text = str(life_bonus_value)
	gems.text = "+" + str(bonus_gems)
	total_score.text = str(total_score_value)
	animation()
	
func calculate_values():
	if Playerstats.bullets_hit > 0:
		accuracy_value = (float(Playerstats.bullets_hit) / float(Playerstats.bullets_shot))
		accuracy_value *= 100 
		accuracy_value = round(accuracy_value)
	else:
		accuracy_value = 0
	time_bonus_value = Playerstats.time_left * 20
	accuracy_bonus_value = accuracy_value * 15
	life_bonus_value = Playerstats.health * 10
	total_score_value = Playerstats.score + time_bonus_value + accuracy_bonus_value + life_bonus_value
	bonus_gems = floor(total_score_value / 15)

func animation():
	await get_tree().create_timer(2.5).timeout
	score.visible = true
	await get_tree().create_timer(0.5).timeout
	time.visible = true
	await get_tree().create_timer(0.5).timeout
	enemies.visible = true
	await get_tree().create_timer(0.5).timeout
	shot.visible = true
	await get_tree().create_timer(0.5).timeout
	hit.visible = true
	await get_tree().create_timer(0.5).timeout
	accuracy.visible = true
	await get_tree().create_timer(0.5).timeout
	time_bonus.visible = true
	await get_tree().create_timer(0.5).timeout
	accuracy_bonus.visible = true
	await get_tree().create_timer(0.5).timeout
	life_bonus.visible = true
	await get_tree().create_timer(0.5).timeout
	gems.visible = true
	await get_tree().create_timer(0.5).timeout
	total_score.visible = true
	await get_tree().create_timer(2.5).timeout
	Playerstats.gems += bonus_gems
	screen.fade_in(0.05,20,"res://Scenes/levels/level_select.tscn")
