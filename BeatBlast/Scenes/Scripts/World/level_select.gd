extends Node2D

@onready var screen = $Fade
@onready var text1 = $Text/High_score_value
@onready var text2 = $Text/High_score_value2
@onready var capsule1 = $Text/Heart_capsule
@onready var capsule2 = $Text/Heart_capsule2
var button_pressed = false

func _ready():
	screen.fade_out(0.1 ,10, 0)
	button_pressed = false
	get_tree().paused = false
	Playerstats.health = Playerstats.max_health
	Playerstats.score = 0
	Playerstats.current_status.Poisoned = 0
	Playerstats.current_status.Blocked = 0
	if Playerstats.levels_unlocked > 1:
		$level_2_select.text = "Level 2 Select"
	else:
		$level_2_select.text = "Beat Level 1 First"
		$level_2_select.disabled = true

func _process(delta: float) -> void:
	text1.text = str(Playerstats.high_scores.Level1HighScore)
	text2.text = str(Playerstats.high_scores.Level2HighScore)
	if Playerstats.items_collected.Level1Heart == 0:
		capsule1.modulate.a = 0.25
	else:
		capsule1.modulate.a = 1
	if Playerstats.items_collected.Level2Heart == 0:
		capsule2.modulate.a = 0.25
	else:
		capsule2.modulate.a = 1
	display()

func _on_store_pressed():
	if not button_pressed:
		screen.fade_in(0.1,10, "res://Scenes/levels/store.tscn")
		get_tree().paused = true
		button_pressed = true

func display():
	var accuracy := 0.0
	if Playerstats.stats.Bullets_shot == 0:
		accuracy = 0
	else:
		accuracy = round((float(Playerstats.stats.Bullets_hit) / float(Playerstats.stats.Bullets_shot)) * 100)
	$Text/Max_hp2.text = str(Playerstats.max_health)
	match Playerstats.attack:
		0:
			$Text/Damage2.text = "0"
		1:
			$Text/Damage2.text = "I"
		2:
			$Text/Damage2.text = "II"
		3:
			$Text/Damage2.text = "III"
		4:
			$Text/Damage2.text = "IV"
		5:
			$Text/Damage2.text = "V"
	match Playerstats.defence:
		0:
			$Text/Defense2.text = "0"
		1:
			$Text/Defense2.text = "I"
		2:
			$Text/Defense2.text = "II"
		3:
			$Text/Defense2.text = "III"
		4:
			$Text/Defense2.text = "IV"
		5:
			$Text/Defense2.text = "V"
	$Text/Bullets_hit2.text = str(Playerstats.stats.Bullets_hit)
	$Text/Bullets_shot2.text = str(Playerstats.stats.Bullets_shot)
	$Text/Accuracy2.text = str(accuracy) + "%"
	$Text/Kills2.text = str(Playerstats.stats.Enemies_defeated)
	$Text/Score2.text = str(Playerstats.stats.Total_score)
	if (Playerstats.stats.Play_time % 60) < 10:
		$Text/Time1.text = "0" + str(Playerstats.stats.Play_time % 60)
	else:
		$Text/Time1.text = str(Playerstats.stats.Play_time % 60)
	$Text/Time2.text = str(floor(Playerstats.stats.Play_time / 60))

func _on_level_1_select_pressed() -> void:
	if not button_pressed:
		Playerstats.level = 1
		screen.fade_in(0.1, 10, "res://Scenes/levels/level1.tscn")
		get_tree().paused = true
		button_pressed = true

func _on_level_2_select_pressed() -> void:
	if not button_pressed:
		Playerstats.level = 2
		screen.fade_in(0.1, 10, "res://Scenes/levels/level2.tscn")
		get_tree().paused = true
		button_pressed = true


func _on_weapon_pressed() -> void:
	if not button_pressed:
		screen.fade_in(0.1,10, "res://Scenes/levels/Weapons.tscn")
		get_tree().paused = true
		button_pressed = true
