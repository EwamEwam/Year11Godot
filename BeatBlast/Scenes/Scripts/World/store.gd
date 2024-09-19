extends Node2D

@onready var screen = $Fade

func _ready() -> void:
	if Playerstats.gems > 9999:
		Playerstats.gems = 9999
	get_tree().paused = false
	screen.fade_out(0.1,10,0)
	display()

func _on_back_pressed() -> void:
	screen.fade_in(0.1,10, "res://Scenes/levels/level_select.tscn")
	get_tree().paused = true
	
func _process(delta: float) -> void:
	$Gem_Value.text = str(Playerstats.gems)
	$Gem_Value2.text = str(Playerstats.gems)

func _on_life_up_upgrade_pressed() -> void:
	if Playerstats.gems >= Playerstats.health_cost and Playerstats.health_lv < 4:
		Playerstats.max_health += 10
		Playerstats.health_lv += 1
		Playerstats.gems -= Playerstats.health_cost
		Playerstats.health_cost += 400
		display()

func _on_defence_up_upgrade_pressed() -> void:
	if Playerstats.gems >= Playerstats.defence_cost and Playerstats.defence_lv < 4:
		Playerstats.defence += 1
		Playerstats.defence_lv += 1
		Playerstats.gems -= Playerstats.defence_cost
		Playerstats.defence_cost += 350
		display()

func _on_attack_up_upgrade_pressed() -> void:
	if Playerstats.gems >= Playerstats.attack_cost and Playerstats.attack_lv < 4:
		Playerstats.attack += 1
		Playerstats.attack_lv += 1
		Playerstats.gems -= Playerstats.attack_cost
		Playerstats.attack_cost += 400
		display()

func display():
	if Playerstats.health_lv < 4:
		$Buttons/Life_up_upgrade.text = str(Playerstats.health_cost)
	else:
		$Buttons/Life_up_upgrade.text = "MAXED"
	$Max_health_heading.text = "+10 Max HP Bottle (Lv " + str(Playerstats.health_lv) + "/4)"
	$Max_health_heading2.text = "+10 Max HP Bottle (Lv " + str(Playerstats.health_lv) + "/4)"
	
	if Playerstats.defence_lv < 5:
		$Buttons/Defence_up_upgrade.text = str(Playerstats.defence_cost)
	else:
		$Buttons/Defence_up_upgrade.text = "MAXED"
	$Defence_heading.text = "Defence Upgrade (Lv " + str(Playerstats.defence_lv) + "/5)"
	$Defence_heading2.text = "Defence Upgrade (Lv " + str(Playerstats.defence_lv) + "/5)"
	
	if Playerstats.attack_lv < 5:
		$Buttons/Attack_up_upgrade.text = str(Playerstats.attack_cost)
	else:
		$Buttons/Attack_up_upgrade.text = "MAXED"
	$Attack_heading.text = "Attack Upgrade (Lv " + str(Playerstats.attack_lv) + "/5)"
	$Attack_heading2.text = "Attack Upgrade (Lv " + str(Playerstats.attack_lv) + "/5)"

	if not Playerstats.grenade_upgrade:
		$Buttons/Grenade_ability_upgrade.text = "2000"
		$Grenade_heading.text = "Grenade Ability (Lv 0/1)"
		$Grenade_heading2.text = "Grenade Ability (Lv 0/1)"
	else:
		$Buttons/Grenade_ability_upgrade.text = "MAXED"
		$Grenade_heading.text = "Grenade Ability (Lv 1/1)"
		$Grenade_heading2.text = "Grenade Ability (Lv 1/1)"

func _on_grenade_ability_upgrade_pressed() -> void:
	if Playerstats.gems >= 2000 and not Playerstats.grenade_upgrade:
		Playerstats.gems -= 2000
		Playerstats.grenade_upgrade = true
		display()

func _on_restore_1_pressed() -> void:
	if Playerstats.gems >= 75:
		Playerstats.gems -= 75
		Playerstats.healing_items.Jar_of_pickled_hearts += 1
		display()

func _on_restore_2_pressed() -> void:
	if Playerstats.gems >= 180:
		Playerstats.gems -= 180
		Playerstats.healing_items.Dried_hearts_in_a_can += 1
		display()

func _on_restore_3_pressed() -> void:
	if Playerstats.gems >= 350:
		Playerstats.gems -= 350
		Playerstats.healing_items.Heart_essence += 1
		display()
