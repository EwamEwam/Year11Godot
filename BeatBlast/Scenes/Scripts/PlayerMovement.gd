extends CharacterBody2D


@export var SPEED = 300.0
@export var ACCELERATION = 20
@export var FRICTION = 20
@onready var Sprite = $AnimatedSprite2D 
@onready var timer = $Timer
const Bullet = preload("res://Scenes/bullet.tscn")
@onready var world = get_node('/root/level')
var direction=Vector2.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


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
	if not timer.is_stopped() or Playerstats.health < 2:
		return
	var bulle = Bullet.instantiate()
	Playerstats.health -= 1
	bulle.global_position = global_position
	bulle.look_at(get_global_mouse_position())
	world.add_child(bulle)
	timer.start()
		
	

