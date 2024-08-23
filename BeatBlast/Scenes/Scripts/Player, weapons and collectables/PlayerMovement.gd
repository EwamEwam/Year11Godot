extends CharacterBody2D
#Lots of variables need to be declared.
@export var SPEED = 500.0
@export var ACCELERATION = 100.0
@export var FRICTION = 70.0
@onready var Sprite = $AnimatedSprite2D 
@onready var Animation_player = $AnimationPlayer
@onready var timer = $Timer
@onready var dash_timer = $Dash_Timer
@onready var wall_collision = $Wall_collision
@onready var spawner = $Bullet_spawner
@onready var light = $Bullet_spawner/Light
const Bullet = preload("res://Scenes/Characters, weapons and collectables/bullet.tscn")
const Bullet2 = preload("res://Scenes/Characters, weapons and collectables/bullet2.tscn")
const Bullet3 = preload("res://Scenes/Characters, weapons and collectables/bullet3.tscn")
const Bullet4 = preload("res://Scenes/Characters, weapons and collectables/bullet4.tscn")
const Bullet5 = preload("res://Scenes/Characters, weapons and collectables/bullet5.tscn")
const Punch_box = preload("res://Scenes/Characters, weapons and collectables/punch_box.tscn")
const gun_particle = preload("res://Scenes/Other/gun_particle.tscn")
const number = preload("res://Scenes/Other/DamageP_numbers.tscn")
const heal_num = preload ("res://Scenes/Other/Heal_numbers.tscn")
const running_particle = preload("res://Scenes/Other/running_particle.tscn")
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
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var particle_timer = 4

signal cooldown
signal dash_cooldown
signal red(val)
signal died

func _ready():
	light.visible = false 

#The function that runs every frame and does all the essential operations like movement, collision check, checking for other actions and running other functions
func _physics_process(delta):
	direction = Input.get_vector("left","right","up","down").normalized()
	if direction:
		if Playerstats.health > 0:
			velocity = velocity.move_toward(direction * SPEED, ACCELERATION)
			particle_check()
		else:
			pass
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	
	Playerstats.player_x = global_position.x
	Playerstats.player_y = global_position.y
	
	if Input.is_action_pressed("shoot"):
		if Playerstats.current_status.Blocked == 0:
				Shoot()
		
	if Input.is_action_just_pressed("Dash"):
		if abs(velocity) > Vector2.ZERO and dash_timer.is_stopped() and Playerstats.health > 0:
			shake(3.5,0.05,3,1.2)
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
		
	if Playerstats.current_status.Poison != 0:
		Sprite.modulate = Color(0.688, 0.99, 0.386,1)
	else:
		Sprite.modulate = Color(1,1,1,1)
	
	check_item_select()
	Update_animation()
	move_and_slide()
	
func particle_check():
	if particle_timer <= 0:
		particle_timer = randi_range(3,4)
		var new_particle = running_particle.instantiate()
		new_particle.global_position = $Particle_spawner.global_position
		add_sibling(new_particle)
		new_particle.set_direction(direction)
	else:
		particle_timer -= 1
	
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
			var new_punch = Punch_box.instantiate()
			new_punch.global_position=global_position
			new_punch.global_position.y += 50
			new_punch.look_at(get_global_mouse_position())
			add_sibling(new_punch)
			emit_signal("cooldown")
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
			shake(7.5,0.05,4,1.25)
			emit_signal("cooldown")
			shoot_animation(0.1)
			make_particles(randi_range(3,4))
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
			shake(12,0.05,6,1.2)
			emit_signal("cooldown")
			shoot_animation(0.2)
			make_particles(randi_range(5,6))
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
			shake(10,0.05,5,1.2)
			emit_signal("cooldown")
			shoot_animation(0.15)
			make_particles(randi_range(6,7))
			timer.start(1.15)
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
			shake(4,0.05,3,1.25)
			emit_signal("cooldown")
			shoot_animation(0.05)
			make_particles(randi_range(2,3))
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
	emit_signal("red", clampf(float(val)/10, 0.35 , 0.95))
	flash()
	await get_tree().create_timer(0.2).timeout
	animation_can_play = true
		
func heal(val):
	Playerstats.health += val
	Playerstats.healnum = val
	var new_heal = heal_num.instantiate()
	new_heal.global_position = global_position
	add_sibling(new_heal)
	
func flash():
	if Playerstats.health > 0:
		for i in range(6):
			Sprite.visible=false
			await get_tree().create_timer(0.05).timeout
			Sprite.visible=true
			await get_tree().create_timer(0.05).timeout
		
#Just uses the camera offset along with a random value to make a shake effect.
func shake(amt,time,rep,damp):
	if Playerstats.health > 0:
		for i in range(rep):
			Camera.offset.x=(randf_range(-amt,amt))
			Camera.offset.y=(randf_range(-amt,amt))
			amt = amt/damp
			await get_tree().create_timer(time).timeout
		Camera.offset.x=0
		Camera.offset.y=0

func dash():
	if not dash_timer.is_stopped():
		return
	SPEED=1800.0
	velocity = velocity.move_toward(direction * SPEED, ACCELERATION*42)
	await get_tree().create_timer(0.11).timeout
	SPEED=500.0
	emit_signal("dash_cooldown")
	dash_timer.start(1.75)

#Hotkeys with the numbers
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
	
func poisoned(time):
	if time > Playerstats.current_status.Poison:
		Playerstats.current_status.Poison = time

#Calculates the mouse position relationship with the player position relationship
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

func make_particles(amt):
	for i in range(amt):
		var new_particle = gun_particle.instantiate()
		new_particle.global_position = spawner.global_position
		add_sibling(new_particle)
		
