extends CanvasLayer

const gems_number = preload("res://Scenes/Other/Gems_numbers.tscn")
@onready var bar = $bar
@onready var red = $RedScreenFade
@onready var heart1 = $heart
@onready var heart2 = $heart2
@onready var heart3 = $heart3
@onready var heart4 = $heart4
@onready var heart5 = $heart5
@onready var heart6 = $heart6
@onready var heart7 = $heart7
@onready var heart8 = $heart8
@onready var heart9 = $heart9
@onready var heart10 = $heart10
@onready var heart11 = $heart11
@onready var heart12 = $heart12
@onready var selection = $WeaponSelector
@onready var hands = $Hands
@onready var pistol = $Pistol
@onready var revolver = $Revovler
@onready var shotgun = $Shotgun
@onready var smg = $SMG
@onready var ak47 = $"AK-47"
@onready var rocket = $Rocket_launcher
@onready var Cooldown_sprite = $Cooldown
@onready var Dash_cooldown = $Dash_cooldown
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var Black_screen = $BlackScreen
@onready var score = $Score
@onready var timer = $Timer
@onready var gems = $Gem_Count
@onready var gem_icon = $Gem

@onready var world = get_node('/root/level')

#now thats a lot of if statements ;)
func _ready():
	player.died.connect(black_screen)
	player.Reload.connect(reloaded)
	player.cooldown.connect(start_cooldown)
	player.dash_cooldown.connect(start_dash_cooldown)
	player.red.connect(damaged)
	Cooldown_sprite.modulate = Color(1.15,1.15,1.15,1)
	Dash_cooldown.modulate = Color(1.15,1.15,1.15,1)
	
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
		
	selection.global_position.x = Playerstats.weapon_selected * 40 - 9
	
	if Playerstats.gems > 999:
		Playerstats.gems = 999
	
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
		for i in range(10):
			red.modulate.a = val
			await get_tree().create_timer(0.075).timeout
			val = val/1.5
		red.visible = false

func black_screen():
	var val = 0
	Black_screen.visible = true
	Black_screen.modulate.a = 0
	await get_tree().create_timer(1).timeout
	for i in range(25):
		Black_screen.visible = true
		val += 0.04
		Black_screen.modulate.a = val
		await get_tree().create_timer(0.035).timeout
	
func reloaded():
	var val = 1
	Black_screen.visible = true
	Black_screen.modulate.a = val
	for i in range(10):
		Black_screen.visible = true
		val -= 0.1
		Black_screen.modulate.a = val
		await get_tree().create_timer(0.035).timeout
	Black_screen.visible = false
