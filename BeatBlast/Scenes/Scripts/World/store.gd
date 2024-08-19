extends Node2D

@onready var screen = $Fade

var health_cost = 400
var health_lv = 0
var defence_cost = 750
var defence_lv = 0
var attack_cost = 1000
var attack_lv = 0

func _ready() -> void:
	screen.fade_out(0.1,10,0)
	get_tree().paused = false

func _on_back_pressed() -> void:
	screen.fade_in(0.1,10, "res://Scenes/levels/level_select.tscn")
	get_tree().paused = true
	
func _process(delta: float) -> void:
	$Gem_Value.text = str(Playerstats.gems)
	$Gem_Value2.text = str(Playerstats.gems)

func _on_life_up_upgrade_pressed() -> void:
	if Playerstats.gems >= health_cost and health_lv < 4:
		Playerstats.max_health += 10
		health_lv += 1
		Playerstats.gems -= health_cost
		health_cost += 400
		if health_lv < 4:
			$Buttons/Life_up_upgrade.text = str(health_cost)
		else:
			$Buttons/Life_up_upgrade.text = "MAXED"
		$Max_health_heading.text = "Max Health Bottle (Lv " + str(health_lv) + "/4)"
		$Max_health_heading2.text = "Max Health Bottle (Lv " + str(health_lv) + "/4)"

func _on_defence_up_upgrade_pressed() -> void:
	if Playerstats.gems >= defence_cost and defence_lv < 4:
		Playerstats.defence += 1
		defence_lv += 1
		Playerstats.gems -= defence_cost
		defence_cost += 350
		if defence_lv < 4:
			$Buttons/Defence_up_upgrade.text = str(defence_cost)
		else:
			$Buttons/Defence_up_upgrade.text = "MAXED"
		$Defence_heading.text = "Defence Upgrade (Lv " + str(defence_lv) + "/4)"
		$Defence_heading2.text = "Defence Upgrade (Lv " + str(defence_lv) + "/4)"
		

func _on_attack_up_upgrade_pressed() -> void:
	if Playerstats.gems >= attack_cost and attack_lv < 4:
		Playerstats.attack += 1
		attack_lv += 1
		Playerstats.gems -= attack_cost
		attack_cost += 400
		if attack_lv < 4:
			$Buttons/Attack_up_upgrade.text = str(attack_cost)
		else:
			$Buttons/Attack_up_upgrade.text = "MAXED"
		$Attack_heading.text = "Attack Upgrade (Lv " + str(attack_lv) + "/4)"
		$Attack_heading2.text = "Attack Upgrade (Lv " + str(attack_lv) + "/4)"
