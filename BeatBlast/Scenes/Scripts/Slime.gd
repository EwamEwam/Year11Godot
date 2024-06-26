extends CharacterBody2D

const SPEED = 200.0
@onready var Sprite = $Slime_sprite
@onready var player = get_tree().get_first_node_in_group("Player")
const heart = preload("res://Scenes/heart5.tscn")
@export var health = 5
@onready var timer = $hurttimer
@export var damage = 1
@onready var hurtbox = $hurtbox

func check_collision():
	if not timer.is_stopped():
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if collision.is_in_group("Player") and timer.is_stopped():
				Playerstats.health -= damage
				player.flash()
				timer.start()

func _physics_process(delta):
	var direction_to_player = global_position.direction_to(player.global_position)
	velocity = direction_to_player * SPEED
	
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
