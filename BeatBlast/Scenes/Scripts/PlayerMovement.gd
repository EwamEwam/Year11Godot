extends CharacterBody2D

@export var SPEED = 300.0
@export var ACCELERATION = 20
@export var FRICTION = 20
@onready var Sprite = $AnimatedSprite2D 
@onready var timer = $Timer
const Bullet = preload("res://Scenes/bullet.tscn")
const Punch_box = preload("res://Scenes/punch_box.tscn")
@onready var world = get_node('/root/level')
var direction=Vector2.ZERO
@onready var Camera = $Camera2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	pass

func _physics_process(delta):
	
	direction = Input.get_vector("left","right","up","down").normalized()
	if direction:
		if Playerstats.health > 0:
			velocity = velocity.move_toward(direction * SPEED, ACCELERATION)
	else:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		
	if velocity.x > 0:
		Sprite.flip_h = true
	elif velocity.x < 0:
		Sprite.flip_h = false
	
	Playerstats.player_x = global_position.x
	Playerstats.player_y = global_position.y
	
	if Input.is_action_pressed("shoot"):
		Shoot()
		
	move_and_slide()
	
func Shoot():
	match Playerstats.weapon_selected:
		1:
			if not timer.is_stopped():
				return
			var new_punch = Punch_box.instantiate()
			new_punch.global_position=global_position
			new_punch.look_at(get_global_mouse_position())
			world.add_child(new_punch)
			timer.start(0.75)
		2:
			if not timer.is_stopped() or Playerstats.health < 2:
				return
			var bulle = Bullet.instantiate()
			Playerstats.health -= 1
			bulle.global_position = global_position
			bulle.look_at(get_global_mouse_position())
			world.add_child(bulle)
			shake(10,0.05,4,1.1)
			timer.start(0.5)
			
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

