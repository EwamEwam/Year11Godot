extends CharacterBody2D

const SPEED = 200.0
const FRICTION = 2.0
@onready var Sprite = $Slime_sprite
@onready var player = get_tree().get_first_node_in_group("Player")
const heart = preload("res://Scenes/heart5.tscn")
@export var health = 5
@onready var timer = $hurttimer
@export var damage = 38
@onready var hurtbox = $hurtbox
@onready var circle = $Movement_circle
@onready var Raycast = $RayCast2D

func check_collision():
	if not timer.is_stopped():
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if collision.is_in_group("Player") and timer.is_stopped():
				collision.shake(35,0.05,10,1.35)
				Playerstats.health -= damage
				player.flash()
				timer.start()

func _physics_process(delta):
	
	Raycast.target_position.x = Playerstats.player_x - global_position.x
	Raycast.target_position.y = Playerstats.player_y - global_position.y
	
	var in_circle = circle.get_overlapping_bodies()
	if in_circle:
		for collision in in_circle:
			if collision.is_in_group("Player") and Raycast.is_colliding()==false:
				var direction_to_player = global_position.direction_to(player.global_position)
				velocity = direction_to_player * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	
	
	if velocity .x > 0:
		Sprite.flip_h = true
	elif velocity.x < 0:
		Sprite.flip_h = false
	
	check_collision()
	move_and_slide()
	
func take_damage(dmg):
	health -= dmg
	if health <= 0:
		queue_free()
		var new_heart = heart.instantiate()
		new_heart.global_position = global_position
		add_sibling(new_heart)
