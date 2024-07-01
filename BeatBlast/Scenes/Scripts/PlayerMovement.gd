extends CharacterBody2D

@export var SPEED = 300.0
@export var ACCELERATION = 20
@export var FRICTION = 20
@onready var Sprite = $AnimatedSprite2D 
@onready var timer = $Timer
const Bullet = preload("res://Scenes/bullet.tscn")
@onready var world = get_node('/root/level')
var direction=Vector2.ZERO
@onready var Camera = $Camera2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	pass

func _physics_process(delta):
	
	direction = Input.get_vector("left","right","up","down").normalized()
	if direction:
		velocity = velocity.move_toward(direction * SPEED, ACCELERATION)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)

	if velocity.x > 0:
		Sprite.flip_h = true
	elif velocity.x < 0:
		Sprite.flip_h = false
		
	if Input.is_action_pressed("shoot"):
		Shoot()
		
	move_and_slide()
	
func Shoot():
	match Playerstats.weapon_selected:
		1:
			pass
		2:
			if not timer.is_stopped() or Playerstats.health < 2:
				return
			var bulle = Bullet.instantiate()
			Playerstats.health -= 1
			bulle.global_position = global_position
			bulle.look_at(get_global_mouse_position())
			world.add_child(bulle)
			shake(10,0.05,4,1.1)
			timer.start()
			
func flash():
	for i in range(4):
		Sprite.visible=false
		await get_tree().create_timer(0.05).timeout
		Sprite.visible=true
		await get_tree().create_timer(0.05).timeout
		
func shake(amt,time,rep,damp):
	for i in range(rep):
		Camera.offset.x=(randi_range(-amt,amt))
		Camera.offset.y=(randi_range(-amt,amt))
		amt = amt/damp
		await get_tree().create_timer(time).timeout
	Camera.offset.x=0
	Camera.offset.y=0

