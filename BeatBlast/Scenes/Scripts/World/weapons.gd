extends Node2D

@onready var screen = $Fade
var weapons_unlocked = Playerstats.weapons_unlocked 
var cost 

func _ready() -> void:
	cost = (weapons_unlocked * 500) - 500
	update_text()
	if Playerstats.gems > 9999:
		Playerstats.gems = 9999
	get_tree().paused = false
	screen.fade_out(0.1,10,0)

func _on_back_pressed() -> void:
	screen.fade_in(0.1,10, "res://Scenes/levels/level_select.tscn")
	get_tree().paused = true
	
func _process(delta: float) -> void:
	cost = (weapons_unlocked * 300) - 300
	update_text()

func update_text() -> void:
	$Text/Gem_Value.text = str(Playerstats.gems)
	$Text/Gem_Value2.text = str(Playerstats.gems)
	$Text/Weapons_unlocked.text = "Weapons Unlocked (" + str(weapons_unlocked) + "/5)"
	$Text/Weapons_unlocked2.text = "Weapons Unlocked (" + str(weapons_unlocked) + "/5)"
	$Text/Weapon_Name.text = "(" + TextData.weapon_names[str(weapons_unlocked-1)] + ")"
	$Text/Weapon_Name2.text = "(" + TextData.weapon_names[str(weapons_unlocked-1)] + ")"
	$Text/Blueprint_count.text = str(Playerstats.blueprints)
	$Text/Blueprint_count2.text = str(Playerstats.blueprints)
	$Sprites/Gun_Sprite.frame = weapons_unlocked - 2
	$Sprites/Gun_Sprite2.frame = weapons_unlocked - 2
	if weapons_unlocked < 5:
		$Text/Gem_Cost.text = str(cost)
		$Text/Gem_Cost2.text = str(cost)
		$Text/Weapon_description.text = TextData.weapon_descriptions[str(weapons_unlocked-1)]
		$Text/Weapon_description2.text = TextData.weapon_descriptions[str(weapons_unlocked-1)]
		$Buttons/Craft.text = "Craft (Costs " + str(cost) + ")"
	else:
		$Text/Gem_Cost.text = "N/A"
		$Text/Gem_Cost2.text = "N/A"
		$Text/Weapon_description.text = "All weapons made!"
		$Text/Weapon_description2.text = "All weapons made!"
		$Buttons/Craft.text = "MAXED"
	
func _on_button_pressed() -> void:
	if Playerstats.gems >= cost and weapons_unlocked < 5 and Playerstats.blueprints > 0:
		weapons_unlocked += 1
		Playerstats.weapons_unlocked += 1
		Playerstats.gems -= cost
		Playerstats.blueprints -= 1
