extends CharacterBody2D

@export var SPEED = 500.0
@export var ACCELERATION = 100.0
@export var FRICTION = 70.0
@onready var Sprite = $AnimatedSprite2D 
@onready var Animation_player = $AnimationPlayer
@onready var timer = $Timer
@onready var dash_timer = $Dash_Timer
@onready var wall_collision = $Wall_collision
const Bullet = preload("res://Scenes/Characters, weapons and collectables/bullet.tscn")
const Bullet2 = preload("res://Scenes/Characters, weapons and collectables/bullet2.tscn")
const Bullet3 = preload("res://Scenes/Characters, weapons and collectables/bullet3.tscn")
const Bullet4 = preload("res://Scenes/Characters, weapons and collectables/bullet4.tscn")
const Bullet5 = preload("res://Scenes/Characters, weapons and collectables/bullet5.tscn")
const Punch_box = preload("res://Scenes/Characters, weapons and collectables/punch_box.tscn")
const number = preload("res://Scenes/Other/DamageP_numbers.tscn")
const heal_num = preload ("res://Scenes/Other/Heal_numbers.tscn")
@onready var world = get_node('/root/level')
var direction=Vector2.ZERO
@onready var Camera = $Camera2D

enum Pointing {Down, Right, Left, Up}
enum State {Idle, Running, Hurt,}
var current_state = State.Idle
var current_direction = Pointing.Right
var last_facing_direction = Vector2(0,1)
var animation_can_play = true
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

signal cooldown
signal dash_cooldown
signal red(val)

func _ready():
	pass

func _physics_process(delta):
	direction = Input.get_vector("left","right","up","down").normalized()
	if direction:
		if Playerstats.health > 0:
			velocity = velocity.move_toward(direction * SPEED, ACCELERATION)
		else:
			return
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	
	Playerstats.player_x = global_position.x
	Playerstats.player_y = global_position.y
	
	if Input.is_action_pressed("shoot"):
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
		if abs(velocity.length()) > 0.1:
			Animation_player.speed_scale = clampf((sqrt(velocity.x * velocity.x + velocity.y * velocity.y)/500),0,1.75)
	else:
		Animation_player.speed_scale = 1
	
	if timer.is_stopped():
		Playerstats.cooldown = 0
	else:
		Playerstats.cooldown = 1
	
	Update_animation()
	move_and_slide()
	
func Update_state():
	if velocity.length() > 0:
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
	else:
		current_state = State.Idle
		
func Update_animation():
	match current_state:
		State.Running:
			match current_direction:
				Pointing.Down:
					var colliding = wall_collision.get_overlapping_bodies()
					if colliding:
						for collision in colliding:
							if collision.is_in_group("Collision"):
								Animation_player.play("Idle_Down")
							else:
								Animation_player.play("Down")
					else:
						Animation_player.play("Down")
				Pointing.Up:
					var colliding = wall_collision.get_overlapping_bodies()
					if colliding:
						for collision in colliding:
							if collision.is_in_group("Collision"):
								Animation_player.play("Idle_Up")
							else:
								Animation_player.play("Up")
					else:
						Animation_player.play("Up")
				Pointing.Right:
					var colliding = wall_collision.get_overlapping_bodies()
					if colliding:
						for collision in colliding:
							if collision.is_in_group("Collision"):
								Animation_player.play("Idle_Right")
							else:
								Animation_player.play("Right")
					else:
						Animation_player.play("Right")
				Pointing.Left:
					var colliding = wall_collision.get_overlapping_bodies()
					if colliding:
						for collision in colliding:
							if collision.is_in_group("Collision"):
								Animation_player.play("Idle_Left")
							else:
								Animation_player.play("Left")
					else:
						Animation_player.play("Left")
		State.Idle:
			match current_direction:
				Pointing.Down:
					Animation_player.play("Idle_Down")
				Pointing.Up:
					Animation_player.play("Idle_Up")
				Pointing.Right:
					Animation_player.play("Idle_Right")
				Pointing.Left:
					Animation_player.play("Idle_Left")
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
	
func Shoot():
	match Playerstats.weapon_selected:
		1:
			if not timer.is_stopped() and Playerstats.health > 0:
				return
			var new_punch = Punch_box.instantiate()
			new_punch.global_position=global_position
			new_punch.look_at(get_global_mouse_position())
			world.add_child(new_punch)
			emit_signal("cooldown")
			timer.start(0.65)
		2:
			if not timer.is_stopped() or Playerstats.health < 2:
				return
			Playerstats.health -= 1
			var bulle = Bullet.instantiate()
			bulle.global_position = global_position
			bulle.look_at(get_global_mouse_position())
			world.add_child(bulle)
			shake(7.5,0.05,4,1.25)
			emit_signal("cooldown")
			timer.start(0.8)
		3:
			if not timer.is_stopped() or Playerstats.health < 3:
				return
			Playerstats.health -= 2
			var bulle5 = Bullet5.instantiate()
			bulle5.global_position = global_position
			bulle5.look_at(get_global_mouse_position())
			world.add_child(bulle5)
			shake(12,0.05,6,1.2)
			emit_signal("cooldown")
			timer.start(1.7)
		4:
			if not timer.is_stopped() or Playerstats.health < 4:
				return
			Playerstats.health -= 4
			for i in range(6):
				var bulle2 = Bullet2.instantiate()
				bulle2.global_position = global_position
				bulle2.look_at(get_global_mouse_position())
				world.add_child(bulle2)
			shake(10,0.05,5,1.2)
			emit_signal("cooldown")
			timer.start(1.15)
		5:
			if not timer.is_stopped() or Playerstats.health < 2:
				return
			Playerstats.health -= 1
			var bulle3 = Bullet3.instantiate()
			bulle3.global_position = global_position
			bulle3.look_at(get_global_mouse_position())
			world.add_child(bulle3)
			shake(4,0.05,3,1.25)
			timer.start(0.2)
		6:
			if not timer.is_stopped() or Playerstats.health < 2:
				return
			Playerstats.health -= 1
			for i in range(2):
				var bulle4 = Bullet4.instantiate()
				bulle4.global_position = global_position
				bulle4.look_at(get_global_mouse_position())
				world.add_child(bulle4)
			shake(2,0.05,3,1.25)
			timer.start(0.1)
	
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
	for i in range(6):
		Sprite.visible=false
		await get_tree().create_timer(0.05).timeout
		Sprite.visible=true
		await get_tree().create_timer(0.05).timeout
		
func shake(amt,time,rep,damp):
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
	SPEED=1500.0
	velocity = velocity.move_toward(direction * SPEED, ACCELERATION*30)
	await get_tree().create_timer(0.12).timeout
	SPEED=500.0
	emit_signal("dash_cooldown")
	dash_timer.start(1.75)
