extends CharacterBody2D

#Lots of variables need to be declared. Probably most are unnesscary. Some for the player physics engine while some are for visuals 
@export var SPEED = 550.0
@export var ACCELERATION = 150.0
@export var FRICTION = 85.0
@onready var Sprite = $AnimatedSprite2D 
@onready var Animation_player = $AnimationPlayer
@onready var timer = $Timer
@onready var dash_timer = $Dash_Timer
@onready var wall_collision = $Wall_collision
@onready var spawner = $Bullet_spawner
@onready var light = $Bullet_spawner/Light
@onready var camera_timer = $Camera_Timer
@onready var burning_light = $Burning_Light
const Bullet = preload("res://Scenes/Characters, weapons and collectables/bullet.tscn")
const Bullet2 = preload("res://Scenes/Characters, weapons and collectables/bullet2.tscn")
const Bullet3 = preload("res://Scenes/Characters, weapons and collectables/bullet3.tscn")
const Bullet4 = preload("res://Scenes/Characters, weapons and collectables/bullet4.tscn")
const Bullet5 = preload("res://Scenes/Characters, weapons and collectables/bullet5.tscn")
const Punch_box = preload("res://Scenes/Characters, weapons and collectables/punch_box.tscn")
const grenade = preload("res://Scenes/Characters, weapons and collectables/heart_grenade.tscn")
const gun_particle = preload("res://Scenes/Other/gun_particle.tscn")
const number = preload("res://Scenes/Other/DamageP_numbers.tscn")
const heal_num = preload ("res://Scenes/Other/Heal_numbers.tscn")
const running_particle = preload("res://Scenes/Other/running_particle.tscn")
const fire_particle = preload("res://Scenes/Other/fire_particle.tscn")
const shell = preload("res://Scenes/Other/Shell_Particle.tscn")
@onready var world = get_node('/root/level')
var direction=Vector2.ZERO
@onready var Camera = $Camera2D

enum Pointing {Down, Right, Left, Up}
enum State {Idle, Running, Hurt, Shooting}
enum Direction_to_mouse {Up, Down, Left, Right, Up_left, Up_right, Down_left, Down_right}
var current_state = State.Idle
var current_direction = Pointing.Up
var Pointing_to_mouse = null
var last_facing_direction = Vector2(0,1)
var animation_can_play = true
var dead = false
var shaking = false
var flashing = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var particle_timer = 4
var camera_offset = Vector2.ZERO
var time_in_level = 0

signal cooldown
signal dash_cooldown
signal red(val)
signal send_text(text)
signal died

#Runs when the player is loaded into the scene.
func _ready():
	shaking = false
	light.visible = false 
	time_in_level = 0
	
#The function that runs every frame and does all the essential operations like movement, collision check, checking for other actions and running other functions
func _physics_process(delta):
	direction = Input.get_vector("left","right","up","down").normalized()
	if direction:
		if Playerstats.health > 0:
			if Playerstats.current_status.Slimed > 0:
				SPEED = 300.0 - (clampi(Playerstats.current_status.Burning,0,1)*80)
			else:
				SPEED = 500.0 - (clampi(Playerstats.current_status.Burning,0,1)*150)
			velocity = velocity.move_toward(direction * SPEED, ACCELERATION)
			particle_check()
		else:
			pass
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	
	if not shaking:
		Camera.offset = camera_offset
	
	Playerstats.player_x = global_position.x
	Playerstats.player_y = global_position.y
	Playerstats.camera_drag = $Camera2D.get_target_position() - global_position
	
	if Input.is_action_pressed("shoot"):
		if Playerstats.current_status.Blocked == 0:
				Shoot()
		
	if Input.is_action_just_pressed("Dash"):
		if abs(velocity) > Vector2.ZERO and dash_timer.is_stopped() and Playerstats.health > 0 and Playerstats.current_status.Slimed == 0:
			shake(8,0.025,8,1.3)
			dash()
		
	if Input.is_action_just_pressed("selectl"):
		if Playerstats.weapon_selected == 1:
			Playerstats.weapon_selected = Playerstats.weapons_unlocked
		else: 
			Playerstats.weapon_selected -= 1
			
	if Input.is_action_just_pressed("selectr"):
		if Playerstats.weapon_selected == Playerstats.weapons_unlocked:
			Playerstats.weapon_selected = 1
		else:
			Playerstats.weapon_selected += 1
	
	if Input.is_action_just_pressed("Heal_selectl"):
		Playerstats.healing_item_selected -= 1
		if Playerstats.healing_item_selected < 1:
			Playerstats.healing_item_selected = 3
	
	if Input.is_action_just_pressed("Heal_selectr"):
		Playerstats.healing_item_selected += 1
		if Playerstats.healing_item_selected > 3:
			Playerstats.healing_item_selected = 1
			
	if Input.is_action_just_pressed("heal"):
		use_healing_item(Playerstats.healing_item_selected)
		
	if Input.is_action_just_pressed("grenade"):
		if Playerstats.health > 8:
			make_heart_grenade()
		
	if animation_can_play:
		Update_state()
		if abs(velocity.length()) > 5 and not current_state == State.Shooting:
			Animation_player.speed_scale = clampf((sqrt(velocity.x * velocity.x + velocity.y * velocity.y)/500),0,1.75)
	else:
		Animation_player.speed_scale = 1
	
	if timer.is_stopped():
		Playerstats.cooldown = 0
	else:
		Playerstats.cooldown = 1
	
	if Playerstats.health < 1:
		death()
		get_tree().paused = true
		
	#Controls the player color during gameplay from status effects.
	if Playerstats.current_status.Poison != 0:
		Sprite.modulate = Color(0.688, 0.99, 0.386,1)
	elif Playerstats.current_status.Burning != 0:
		Sprite.modulate = Color(0.8,0.8,0.8,1)
	elif not flashing:
		Sprite.modulate = Color(1,1,1,1)
	else:
		clampf(Sprite.modulate.r, 1, 7)
		clampf(Sprite.modulate.g, 1, 7)
		clampf(Sprite.modulate.b, 1, 7)

	check_item_select()
	Update_animation()
	move_and_slide()
	set_camera_offset()
	
#Uses the healing_items dictionary in the playerstats script to check the player's inventory of healing items
func use_healing_item(val):
	match val:
		1:
			if Playerstats.healing_items.Jar_of_pickled_hearts > 0 and Playerstats.healing_cooldown < 1:
				heal(20)
				Playerstats.healing_items.Jar_of_pickled_hearts -= 1
				Playerstats.healing_cooldown = 45
				$Audio_Players/Heal.play()
		2:
			if Playerstats.healing_items.Dried_hearts_in_a_can > 0 and Playerstats.healing_cooldown < 1:
				heal(50)
				Playerstats.healing_items.Dried_hearts_in_a_can -= 1
				Playerstats.healing_cooldown = 60
				$Audio_Players/Heal.play()
		3:
			if Playerstats.healing_items.Heart_essence > 0 and Playerstats.healing_cooldown < 1:
				heal(100)
				Playerstats.healing_items.Heart_essence -= 1
				Playerstats.healing_cooldown = 75
				$Audio_Players/Heal.play()
	
#Whenever the player's moving, it causes the particle timer to go down by one each frame. When it reaches zero. It creates a particle 
func particle_check():
	if particle_timer <= 0:
		particle_timer = randi_range(3,4)
		var new_particle = running_particle.instantiate()
		new_particle.global_position = $Particle_spawner.global_position
		add_sibling(new_particle)
		new_particle.set_direction(direction)
	else:
		particle_timer -= 1

#Takes the sine / cosine of the time in the level for camera bob effect
func set_camera_offset() -> void:
	camera_offset = 15 * Vector2(sin(deg_to_rad(28 * time_in_level)), cos(deg_to_rad(30 * time_in_level)))
	
#emits a signal when the player health reaches 0
func death():
	emit_signal("died")
	
#Updates the player's state based on where they are facing and if they are moving.
func Update_state():
	if velocity.length() > 0 and not current_state == State.Shooting:
		current_state = State.Running
		if abs(direction.x) < 0.1:
			if direction.y > 0:
				current_direction = Pointing.Down
				wall_collision.position = Vector2(0,17)
				wall_collision.rotation = 0
			elif direction.y < 0:
				current_direction = Pointing.Up
				wall_collision.position = Vector2(0,-1)
				wall_collision.rotation = 0
		else:
			if direction.x > 0:
				current_direction = Pointing.Right
				wall_collision.position = Vector2(8,8)
				wall_collision.rotation = deg_to_rad(90)
			elif direction.x < 0:
				current_direction = Pointing.Left
				wall_collision.position = Vector2(-8,8)
				wall_collision.rotation = deg_to_rad(90)
	elif not current_state == State.Shooting:
		current_state = State.Idle
		
	if Playerstats.current_status.Burning > 0:
		burning_light.visible = true
		if randi_range(1,8) == 1:
			var new_particle = fire_particle.instantiate()
			new_particle.global_position = global_position
			new_particle.global_position += Vector2(randf_range(-25,25),randf_range(-60,60))
			add_sibling(new_particle)
	else:
		burning_light.visible = false
			
#function for player animation. matches the current state the player, then the current direction the player is facing
func Update_animation():
	match current_state:
		State.Running:
			match current_direction:
				Pointing.Down:
					var colliding = wall_collision.get_overlapping_bodies()
					if colliding:
						for collision in colliding:
							if collision.is_in_group("Collision"):
								Animation_player.play("Idle_Down"+ str(Playerstats.weapon_selected))
							else:
								Animation_player.play("Down" + str(Playerstats.weapon_selected))
					else:
						Animation_player.play("Down" + str(Playerstats.weapon_selected))
				Pointing.Up:
					var colliding = wall_collision.get_overlapping_bodies()
					if colliding:
						for collision in colliding:
							if collision.is_in_group("Collision"):
								Animation_player.play("Idle_Up" + str(Playerstats.weapon_selected))
							else:
								Animation_player.play("Up" + str(Playerstats.weapon_selected))
					else:
						Animation_player.play("Up" + str(Playerstats.weapon_selected))
				Pointing.Right:
					var colliding = wall_collision.get_overlapping_bodies()
					if colliding:
						for collision in colliding:
							if collision.is_in_group("Collision"):
								Animation_player.play("Idle_Right" + str(Playerstats.weapon_selected))
							else:
								Animation_player.play("Right" + str(Playerstats.weapon_selected))
					else:
						Animation_player.play("Right" + str(Playerstats.weapon_selected))
				Pointing.Left:
					var colliding = wall_collision.get_overlapping_bodies()
					if colliding:
						for collision in colliding:
							if collision.is_in_group("Collision"):
								Animation_player.play("Idle_Left" + str(Playerstats.weapon_selected))
							else:
								Animation_player.play("Left" + str(Playerstats.weapon_selected))
					else:
						Animation_player.play("Left" + str(Playerstats.weapon_selected))
		State.Idle:
			match current_direction:
				Pointing.Down:
					Animation_player.play("Idle_Down" + str(Playerstats.weapon_selected))
				Pointing.Up:
					Animation_player.play("Idle_Up" + str(Playerstats.weapon_selected))
				Pointing.Right:
					Animation_player.play("Idle_Right" + str(Playerstats.weapon_selected))
				Pointing.Left:
					Animation_player.play("Idle_Left" + str(Playerstats.weapon_selected))
		State.Hurt:
			match current_direction:
				Pointing.Down:
					Animation_player.play("Hurt_Down")
				Pointing.Up:
					Animation_player.play("Hurt_Up")
				Pointing.Right:
					Animation_player.play("Hurt_Right")
				Pointing.Left:
					Animation_player.play("Hurt_Left")

#Function for when the player shoots, the selected weapon will match with one of these scripts and a bullet will spawn
func Shoot():
	match Playerstats.weapon_selected:
		1:
			if not timer.is_stopped() and Playerstats.health > 0:
				return
			get_mouse_direction()
			var new_punch = Punch_box.instantiate()
			new_punch.global_position=global_position
			new_punch.global_position.y += 50
			new_punch.look_at(get_global_mouse_position())
			add_sibling(new_punch)
			shoot_animation(0.125)
			emit_signal("cooldown")
			$Audio_Players/Punch.play()
			timer.start(0.65)
		2:
			if not timer.is_stopped() or Playerstats.health < 2:
				return
			Playerstats.health -= 1
			get_mouse_direction()
			set_spawner(Pointing_to_mouse)
			var bulle = Bullet.instantiate()
			bulle.global_position = spawner.global_position
			bulle.look_at(get_global_mouse_position())
			add_sibling(bulle)
			shake(12.5,0.025,12.5,1.2)
			emit_signal("cooldown")
			shoot_animation(0.1)
			make_shell(1,1)
			make_particles(randi_range(5,6))
			$Audio_Players/Gun3.play()
			timer.start(0.75)
		3:
			if not timer.is_stopped() or Playerstats.health < 3:
				return
			Playerstats.health -= 2
			get_mouse_direction()
			set_spawner(Pointing_to_mouse)
			var bulle5 = Bullet5.instantiate()
			bulle5.global_position = spawner.global_position
			bulle5.look_at(get_global_mouse_position())
			add_sibling(bulle5)
			shake(25,0.025,25,1.2)
			emit_signal("cooldown")
			shoot_animation(0.2)
			make_shell(1,1)
			make_particles(randi_range(8,9))
			$Audio_Players/Gun4.play()
			timer.start(2)
		4:
			if not timer.is_stopped() or Playerstats.health < 5:
				return
			Playerstats.health -= 4
			get_mouse_direction()
			set_spawner(Pointing_to_mouse)
			for i in range(6):
				var bulle2 = Bullet2.instantiate()
				bulle2.global_position = spawner.global_position
				bulle2.look_at(get_global_mouse_position())
				add_sibling(bulle2)
			shake(28,0.025,28,1.2)
			emit_signal("cooldown")
			shoot_animation(0.15)
			make_particles(randi_range(7,8))
			make_shell(2,6)
			timer.start(1.35)
			$Audio_Players/Gun2.play()
		5:
			if not timer.is_stopped() or Playerstats.health < 2:
				return
			Playerstats.health -= 1
			get_mouse_direction()
			set_spawner(Pointing_to_mouse)
			var bulle3 = Bullet3.instantiate()
			bulle3.global_position = spawner.global_position
			bulle3.look_at(get_global_mouse_position())
			add_sibling(bulle3)
			shake(9,0.025,9,1.2)
			emit_signal("cooldown")
			shoot_animation(0.05)
			make_particles(randi_range(4,5))
			make_shell(1,1)
			$Audio_Players/Gun1.play()
			timer.start(0.25)
		6:
			if not timer.is_stopped() or Playerstats.health < 2:
				return
			Playerstats.health -= 1
			for i in range(2):
				var bulle4 = Bullet4.instantiate()
				bulle4.global_position = global_position
				bulle4.look_at(get_global_mouse_position())
				add_sibling(bulle4)
			shake(2,0.05,3,1.25)
			timer.start(0.1)
	
#Manually matches all the states and animation
func shoot_animation(time):
	current_state = State.Shooting
	match Pointing_to_mouse:
		Direction_to_mouse.Down:
			Animation_player.speed_scale = 1
			Animation_player.play("Shoot_down" + str(Playerstats.weapon_selected))
			await get_tree().create_timer(time).timeout
			current_state = State.Idle
		Direction_to_mouse.Right:
			Animation_player.speed_scale = 1
			Animation_player.play("Shoot_right" + str(Playerstats.weapon_selected))
			await get_tree().create_timer(time).timeout
			current_state = State.Idle
		Direction_to_mouse.Up:
			Animation_player.speed_scale = 1
			Animation_player.play("Shoot_up" + str(Playerstats.weapon_selected))
			await get_tree().create_timer(time).timeout
			current_state = State.Idle
		Direction_to_mouse.Left:
			Animation_player.speed_scale = 1
			Animation_player.play("Shoot_left" + str(Playerstats.weapon_selected))
			await get_tree().create_timer(time).timeout
			current_state = State.Idle
		Direction_to_mouse.Down_left:
			Animation_player.speed_scale = 1
			Animation_player.play("Shoot_down_left" + str(Playerstats.weapon_selected))
			await get_tree().create_timer(time).timeout
			current_state = State.Idle
		Direction_to_mouse.Down_right:
			Animation_player.speed_scale = 1
			Animation_player.play("Shoot_down_right" + str(Playerstats.weapon_selected))
			await get_tree().create_timer(time).timeout
			current_state = State.Idle
		Direction_to_mouse.Up_right:
			Animation_player.speed_scale = 1
			Animation_player.play("Shoot_up_right" + str(Playerstats.weapon_selected))
			await get_tree().create_timer(time).timeout
			current_state = State.Idle
		Direction_to_mouse.Up_left:
			Animation_player.speed_scale = 1
			Animation_player.play("Shoot_up_left" + str(Playerstats.weapon_selected))
			await get_tree().create_timer(time).timeout
			current_state = State.Idle
			
#Script for when the player takes damage, emits a signal along with a number to the HUD script for the red damage effect
func damage_player(val):
	if val < 1:
		val = 1
	animation_can_play = false
	current_state = State.Hurt
	Playerstats.health -= val
	Playerstats.dampval = val
	var new_number = number.instantiate()
	new_number.global_position=global_position
	add_sibling(new_number)
	emit_signal("red", clampf(float(val)/5, 0.5 , 1.5))
	$Audio_Players/Hurt.play()
	flash()
	await get_tree().create_timer(0.2).timeout
	animation_can_play = true
		
#Script for healing 
func heal(val):
	Playerstats.health += val
	Playerstats.healnum = val
	var new_heal = heal_num.instantiate()
	new_heal.global_position = global_position
	add_sibling(new_heal)
	
#Flash effect, turns the player's sprite off and on 6 times.
func flash():
	flashing = true
	Sprite.modulate = Color(7,7,7,1)
	if Playerstats.health > 0:
		for i in range(6):
			Sprite.visible=false
			await get_tree().create_timer(0.05).timeout
			Sprite.visible=true
			await get_tree().create_timer(0.05).timeout
			if Sprite.modulate.r > 2:
				Sprite.modulate -= Color(1,1,1,0)
	Sprite.modulate = Color(1,1,1,1)
	flashing = false

#Just uses the camera offset along with a random value to make a shake effect.
func shake(amt,time,rep,damp):
	shaking = true
	if Playerstats.health > 0:
		for i in range(rep):
			if Playerstats.settings.Allow_Shaking:
				shaking = true
				Camera.offset.x=(randf_range(-amt,amt))
				Camera.offset.y=(randf_range(-amt,amt))
				Camera.offset += camera_offset
				amt = amt/damp
				await get_tree().create_timer(time).timeout
	shaking = false

#Dash function, temperoailiy sets the player speed to 2100 for 0.3 seconds before setting it back down to 550.
func dash():
	if not dash_timer.is_stopped():
		return
	dash_timer.start(1.75)
	emit_signal("dash_cooldown")
	SPEED= 2100.0
	velocity = velocity.move_toward(direction * SPEED, ACCELERATION*75)
	await get_tree().create_timer(0.3).timeout
	SPEED= 550.0
	
#Hotkeys with the numbers, the game manually checks each one
func check_item_select():
	if Input.is_action_just_pressed("1"):
		Playerstats.weapon_selected = 1
	if Input.is_action_just_pressed("2") and Playerstats.weapons_unlocked > 1:
		Playerstats.weapon_selected = 2
	if Input.is_action_just_pressed("3") and Playerstats.weapons_unlocked > 2:
		Playerstats.weapon_selected = 3
	if Input.is_action_just_pressed("4") and Playerstats.weapons_unlocked > 3:
		Playerstats.weapon_selected = 4
	if Input.is_action_just_pressed("5") and Playerstats.weapons_unlocked > 4:
		Playerstats.weapon_selected = 5
	if Input.is_action_just_pressed("6") and Playerstats.weapons_unlocked > 5:
		Playerstats.weapon_selected = 6
	
#Status Effects Function, They apply when an enemy hits the player and the time variable associated with the enemt is lower than the current status timer
func poisoned(time):
	if time > Playerstats.current_status.Poison:
		Playerstats.current_status.Poison = time

func blocked(time):
	if time > Playerstats.current_status.Blocked:
		Playerstats.current_status.Blocked = time

func slimed(time):
	if time > Playerstats.current_status.Slimed:
		Playerstats.current_status.Slimed = time
		
func burned(time):
	if time > Playerstats.current_status.Burning:
		Playerstats.current_status.Burning = time

#Calculates the mouse position relationship with the player position relationship. Does this manually with if and else statements.
func get_mouse_direction():
	var difference_in_y = get_global_mouse_position().y - global_position.y
	var difference_in_x = get_global_mouse_position().x - global_position.x
	if difference_in_y < 0:
		if abs(difference_in_x) > 200:
			if abs(difference_in_y) > 125:
				if difference_in_x > 0:
					Pointing_to_mouse = Direction_to_mouse.Up_right
				else:
					Pointing_to_mouse = Direction_to_mouse.Up_left
			elif difference_in_x > 0:
				Pointing_to_mouse = Direction_to_mouse.Right
			else:
				Pointing_to_mouse = Direction_to_mouse.Left
		else:
			Pointing_to_mouse = Direction_to_mouse.Up
	else:
		if abs(difference_in_x) > 200:
			if abs(difference_in_y) > 125:
				if difference_in_x > 0:
					Pointing_to_mouse = Direction_to_mouse.Down_right
				else:
					Pointing_to_mouse = Direction_to_mouse.Down_left
			elif difference_in_x > 0:
				Pointing_to_mouse = Direction_to_mouse.Right
			else:
				Pointing_to_mouse = Direction_to_mouse.Left
		else:
			Pointing_to_mouse = Direction_to_mouse.Down
		
#Sets the bullet spawner when the player shoots
func set_spawner(val):
	match val:
		Direction_to_mouse.Down:
			spawner.position = Vector2(0,4)
			light.visible = true
			light.energy = 80
			for i in range(2):
				await get_tree().create_timer(0.075).timeout
				light.energy -= 40
			light.visible = false
		Direction_to_mouse.Left:
			spawner.position = Vector2(-8,-1)
			light.visible = true
			light.energy = 80
			for i in range(2):
				await get_tree().create_timer(0.075).timeout
				light.energy -= 40
			light.visible = false
		Direction_to_mouse.Up:
			spawner.position = Vector2(0,-4)
			light.visible = true
			light.energy = 10
			for i in range(2):
				await get_tree().create_timer(0.075).timeout
				light.energy -= 5
			light.visible = false
		Direction_to_mouse.Right:
			spawner.position = Vector2(8,-1)
			light.visible = true
			light.energy = 80
			for i in range(2):
				await get_tree().create_timer(0.075).timeout
				light.energy -= 40
			light.visible = false
		Direction_to_mouse.Down_left:
			spawner.position = Vector2(-7,1)
			light.visible = true
			light.energy = 80
			for i in range(2):
				await get_tree().create_timer(0.075).timeout
				light.energy -= 40
			light.visible = false
		Direction_to_mouse.Down_right:
			spawner.position = Vector2(7,1)
			light.visible = true
			light.energy = 80
			for i in range(2):
				await get_tree().create_timer(0.075).timeout
				light.energy -= 40
			light.visible = false
		Direction_to_mouse.Up_right:
			spawner.position = Vector2(6,-2)
			light.visible = true
			light.energy = 10
			for i in range(2):
				await get_tree().create_timer(0.075).timeout
				light.energy -= 5
			light.visible = false
		Direction_to_mouse.Up_left:
			spawner.position = Vector2(-6,2)
			light.visible = true
			light.energy = 10
			for i in range(2):
				await get_tree().create_timer(0.075).timeout
				light.energy -= 5
			light.visible = false

#Function which makes the particles when the player shoots their gun
func make_particles(amt):
	for i in range(amt):
		var new_particle = gun_particle.instantiate()
		new_particle.global_position = spawner.global_position
		add_sibling(new_particle)
		
#Used to find the timer spent in the level.
func _on_camera_timer_timeout() -> void:
	time_in_level += 0.017
	set_camera_offset()

#Generates the step sound from the audiostreamplayer2Ds. 
func step_sound() -> void:
	if randi_range(0,1):
		$Audio_Players/Step1.pitch_scale = randf_range(1.1,1.3)
		$Audio_Players/Step1.play()
	else:
		$Audio_Players/Step2.pitch_scale = randf_range(1.15,1.35)
		$Audio_Players/Step2.play()

#Generates the shell particle when the player shoots
func make_shell(type, amt):
	for i in range(amt):
		var new_shell = shell.instantiate()
		new_shell.global_position = spawner.global_position
		new_shell.set_type(type)
		add_sibling(new_shell)

func make_heart_grenade():
	if Playerstats.grenade_upgrade and Playerstats.grenade_cooldown < 1:
		Playerstats.health -= 8
		var new_grenade = grenade.instantiate()
		new_grenade.global_position = global_position
		add_sibling(new_grenade)
		Playerstats.grenade_cooldown = 45

#Functions for the sign text system, one is for showing it while the other is for hiding it.
func show_sign_text():
	var length = Playerstats.sign_text.length()
	var text_buffer = ""
	var current_letter = 0
	for i in range(length):
		text_buffer += Playerstats.sign_text[current_letter]
		current_letter += 1
		await get_tree().create_timer(0.025).timeout
		emit_signal("send_text", text_buffer)
		if Playerstats.sign_text.length() != length:
			$Hud/CanvasModulate/Sign_texts/text.text = ""
			break
		
func hide_text():
	$Hud/CanvasModulate/Sign_texts/text.text = ""
	Playerstats.sign_text = ""
	
