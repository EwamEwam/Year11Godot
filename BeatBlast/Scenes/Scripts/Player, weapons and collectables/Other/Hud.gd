extends CanvasLayer

@onready var bar = $bar
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
@onready var player = get_tree().get_first_node_in_group("Player")

#now thats a lot of if statements ;)
func _ready():
	player.cooldown.connect(start_cooldown)
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
		
	selection.global_position.x = Playerstats.weapon_selected * 40 - 9
	
	if Playerstats.health > Playerstats.max_health:
		Playerstats.health = Playerstats.max_health
		
	if Playerstats.cooldown == 0:
		Cooldown_sprite.play(var_to_str(Playerstats.weapon_selected + 100))
		
func start_cooldown():
	Cooldown_sprite.play(var_to_str(Playerstats.weapon_selected))
	Cooldown_sprite.speed_scale = 1

func _on_cooldown_animation_finished():
	Playerstats.cooldown = 0
	Cooldown_sprite.play(var_to_str(Playerstats.weapon_selected + 100))
