extends CanvasLayer
#Script for the player's hud, all the nodes are declared as variables.
const gems_number = preload("res://Scenes/Other/Gems_numbers.tscn")
@onready var bar = $CanvasModulate/bar
@onready var red = $CanvasModulate/RedScreenFade
@onready var heart1 = $CanvasModulate/heart
@onready var heart2 = $CanvasModulate/heart2
@onready var heart3 = $CanvasModulate/heart3
@onready var heart4 = $CanvasModulate/heart4
@onready var heart5 = $CanvasModulate/heart5
@onready var heart6 = $CanvasModulate/heart6
@onready var heart7 = $CanvasModulate/heart7
@onready var heart8 = $CanvasModulate/heart8
@onready var heart9 = $CanvasModulate/heart9
@onready var heart10 = $CanvasModulate/heart10
@onready var heart11 = $CanvasModulate/heart11
@onready var heart12 = $CanvasModulate/heart12
@onready var selection = $CanvasModulate/WeaponSelector
@onready var hands = $CanvasModulate/Hands
@onready var pistol = $CanvasModulate/Pistol
@onready var revolver = $CanvasModulate/Revovler
@onready var shotgun = $CanvasModulate/Shotgun
@onready var smg = $CanvasModulate/SMG
@onready var ak47 = $"CanvasModulate/AK-47"
@onready var rocket = $CanvasModulate/Rocket_launcher
@onready var Cooldown_sprite = $CanvasModulate/Cooldown
@onready var Dash_cooldown = $CanvasModulate/Dash_cooldown
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var score = $CanvasModulate/Score
@onready var timer = $CanvasModulate/Timer
@onready var gems = $CanvasModulate/Gem_Count
@onready var gem_icon = $CanvasModulate/Gem
@onready var poison = $CanvasModulate/Poison
@onready var poison_timer = $CanvasModulate/Poison_timer
@onready var blocked = $CanvasModulate/Blocked
@onready var blocked_timer = $CanvasModulate/Blocked_timer
@onready var slimed = $CanvasModulate/Slimed
@onready var slimed_timer = $CanvasModulate/Slimed_timer
@onready var burning = $CanvasModulate/Burning
@onready var burning_timer = $CanvasModulate/Burning_timer
@onready var hud = $CanvasModulate
@onready var level_heading = $CanvasModulate/Level_Title

@onready var key = get_tree().get_first_node_in_group("Key")
@onready var world = get_node('/root/level')

#now thats a lot of if statements ;)
func _ready():
	player.died.connect(fade)
	player.cooldown.connect(start_cooldown)
	player.dash_cooldown.connect(start_dash_cooldown)
	player.red.connect(damaged)
	Cooldown_sprite.modulate = Color(1.15,1.15,1.15,1)
	Dash_cooldown.modulate = Color(1.15,1.15,1.15,1)
	level_title()
	
	if key != null:
		key.level_complete.connect(fade_level_complete)
		
	hands.visible = true
	pistol.visible = false
	revolver.visible = false
	shotgun.visible = false
	smg.visible = false
	ak47.visible = false
	rocket.visible = false
	
	if Playerstats.weapons_unlocked > 1:
		pistol.visible = true
	if Playerstats.weapons_unlocked > 2:
		revolver.visible = true
	if Playerstats.weapons_unlocked > 3:
		shotgun.visible = true
	if Playerstats.weapons_unlocked > 4:
		smg.visible = true
	if Playerstats.weapons_unlocked > 5:
		ak47.visible = true
	if Playerstats.weapons_unlocked > 6:
		rocket.visible = true
	
	hud.modulate.a = 0
	await get_tree().create_timer(1).timeout
	for i in range(20):
		hud.modulate.a += 0.05
		await get_tree().create_timer(0.05).timeout
		
#Manually Sets the frame of each heart sprite.
func _physics_process(delta):
	bar.set_frame(Playerstats.max_health/10-3)
	heart1.set_frame(clampf(Playerstats.health,0,10))
	heart2.set_frame(clampf(Playerstats.health-10,0,10))
	heart3.set_frame(clampf(Playerstats.health-20,0,10))
	heart4.set_frame(clampf(Playerstats.health-30,0,10))
	heart5.set_frame(clampf(Playerstats.health-40,0,10))
	heart6.set_frame(clampf(Playerstats.health-50,0,10))
	heart7.set_frame(clampf(Playerstats.health-60,0,10))
	heart8.set_frame(clampf(Playerstats.health-70,0,10))
	heart9.set_frame(clampf(Playerstats.health-80,0,10))
	heart10.set_frame(clampf(Playerstats.health-90,0,10))
	heart11.set_frame(clampf(Playerstats.health-100,0,10))
	heart12.set_frame(clampf(Playerstats.health-110,0,10))
	
	if Playerstats.max_health < 40:
		heart4.visible=false
	else:
		heart4.visible=true

	if Playerstats.max_health < 50:
		heart5.visible=false
	else:
		heart5.visible=true

	if Playerstats.max_health < 60:
		heart6.visible=false
	else:
		heart6.visible=true

	if Playerstats.max_health < 70:
		heart7.visible=false
	else:
		heart7.visible=true

	if Playerstats.max_health < 80:
		heart8.visible=false
	else:
		heart8.visible=true
		
	if Playerstats.max_health < 90:
		heart9.visible=false
	else:
		heart9.visible=true
		
	if Playerstats.max_health < 100:
		heart10.visible=false
	else:
		heart10.visible=true
		
	if Playerstats.max_health < 110:
		heart11.visible=false
	else:
		heart11.visible=true
		
	if Playerstats.max_health < 120:
		heart12.visible=false
	else:
		heart12.visible=true
		
	score.text = var_to_str(Playerstats.score)
	timer.text = var_to_str(world.timer)
	gems.text = var_to_str(Playerstats.gems)
		
	selection.global_position.x = Playerstats.weapon_selected * 40 - 12
	
	if Playerstats.gems > 9999:
		Playerstats.gems = 9999
	
	if Playerstats.health > Playerstats.max_health:
		Playerstats.health = Playerstats.max_health
		
	if Playerstats.cooldown == 0:
		Cooldown_sprite.play(var_to_str(Playerstats.weapon_selected + 100))
		
	if Playerstats.gemsval != 0:
		var new_number = gems_number.instantiate()
		new_number.global_position = gem_icon.global_position
		new_number.global_position.y -= 20
		add_child(new_number)
		Playerstats.gemsval = 0
		
	update_status()
	update_healing_items(Playerstats.healing_item_selected)
#These function each control one part of the HUD. For example, the cooldown metres, the red screen damage effect and the status effect timers
func start_dash_cooldown():
	Dash_cooldown.play("running")
	Dash_cooldown.speed_scale = 1
	
func start_cooldown():
	Cooldown_sprite.play(var_to_str(Playerstats.weapon_selected))
	Cooldown_sprite.speed_scale = 1

func _on_cooldown_animation_finished():
	Playerstats.cooldown = 0
	Cooldown_sprite.play(var_to_str(Playerstats.weapon_selected + 100))

func _on_dash_cooldown_animation_finished():
	Dash_cooldown.speed_scale = 0
	Dash_cooldown.play("still")
	
func damaged(val):
	if Playerstats.health > 0:
		red.visible = true
		for i in range(30):
			red.modulate.a = val
			await get_tree().create_timer(0.025).timeout
			val = val/1.2
		red.visible = false

func update_status():
	if Playerstats.current_status.Poison > 0:
		poison.visible = true
		poison_timer.visible = true
		poison_timer.text = var_to_str(Playerstats.current_status.Poison)
	else:
		poison.visible = false
		poison_timer.visible = false
	if Playerstats.current_status.Blocked > 0:
		blocked.visible = true
		blocked_timer.visible = true
		blocked_timer.text = var_to_str(Playerstats.current_status.Blocked)
	else:
		blocked.visible = false
		blocked_timer.visible = false
	if Playerstats.current_status.Slimed > 0:
		slimed.visible = true
		slimed_timer.visible = true
		slimed_timer.text = var_to_str(Playerstats.current_status.Slimed)
	else:
		slimed.visible = false
		slimed_timer.visible = false
	if Playerstats.current_status.Burning > 0:
		burning.visible = true
		burning_timer.visible = true
		burning_timer.text = var_to_str(Playerstats.current_status.Burning)
	else:
		burning.visible = false
		burning_timer.visible = false

func fade():
	await get_tree().create_timer(3).timeout
	for i in range(20):
		hud.modulate.a -= 0.05
		await get_tree().create_timer(0.05).timeout

func fade_level_complete():
	for i in range(5):
		hud.modulate.a -= 0.2
		await get_tree().create_timer(0.05).timeout

func level_title() -> void:
	level_heading.text = "Level " + str(Playerstats.level)
	level_heading.modulate.a = 0
	await get_tree().create_timer(0.5).timeout
	for i in range(20):
		level_heading.modulate.a += 0.05
		await get_tree().create_timer(0.05).timeout
	await get_tree().create_timer(1).timeout
	for i in range(20):
		level_heading.modulate.a -= 0.05
		await get_tree().create_timer(0.05).timeout
	level_heading.visible = false

func update_healing_items(selected):
	$CanvasModulate/Healing_icon.play(str(selected))
	match selected:
		1:
			$CanvasModulate/Healing_amt.text = "X" + str(Playerstats.healing_items["Jar_of_pickled_hearts"])
		2:
			$CanvasModulate/Healing_amt.text = "X" + str(Playerstats.healing_items["Dried_hearts_in_a_can"])
		3:
			$CanvasModulate/Healing_amt.text = "X" + str(Playerstats.healing_items["Heart_essence"])
	$CanvasModulate/Healing_icon.play(str(selected))
	if Playerstats.healing_cooldown > 0:
		$CanvasModulate/HealthHeal.modulate = Color(0.5,0.5,0.5,1)
		$CanvasModulate/Healing_icon.modulate = Color(0.5,0.5,0.5,1)
		$CanvasModulate/Healing_amt.modulate = Color(0.5,0.5,0.5,1)
		$CanvasModulate/Healing_cooldown.visible = true
		$CanvasModulate/Healing_cooldown.text = str(Playerstats.healing_cooldown)
	else:
		$CanvasModulate/HealthHeal.modulate = Color(1,1,1,1)
		$CanvasModulate/Healing_icon.modulate = Color(1,1,1,1)
		$CanvasModulate/Healing_amt.modulate = Color(1,1,1,1)
		$CanvasModulate/Healing_cooldown.visible = false
