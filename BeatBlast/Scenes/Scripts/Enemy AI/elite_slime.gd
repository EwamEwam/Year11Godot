extends CharacterBody2D

const SPEED = 12500
const ACCELLERATION = 20.0
const FRICTION = 7.0
var score_value = 250
@onready var Sprite = $Slime_sprite
@onready var player = get_tree().get_first_node_in_group("Player")
const heart = preload("res://Scenes/Characters, weapons and collectables/heart5.tscn")
const score = preload("res://Scenes/Other/Score_numbers.tscn")
@export var health = 100
@onready var timer = $hurttimer
@export var damage = 21
@onready var hurtbox = $hurtbox
@onready var circle = $Movement_circle
@onready var Raycast = $RayCast2D

func check_collision():
	if not timer.is_stopped() or health < 0:
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if collision.is_in_group("Player") and timer.is_stopped() and collision.has_method("damage_player"):
				collision.shake(35,0.05,10,1.35)
				collision.damage_player(damage)
				player.flash()
				timer.start()
				
func _physics_process(delta):
	
	Raycast.target_position.x = Playerstats.player_x - global_position.x
	Raycast.target_position.y = Playerstats.player_y - global_position.y
	
	if health > 0:
		var in_circle = circle.get_overlapping_bodies()
		if in_circle:
			for collision in in_circle:
				if collision.is_in_group("Player") and Raycast.is_colliding()==false:
					var direction_to_player = global_position.direction_to(player.global_position)
					velocity = velocity.move_toward(direction_to_player * clampf(SPEED/clampf((health/1),1,100),210,380), ACCELLERATION)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	else:
		velocity = Vector2.ZERO
		
	if velocity .x > 0:
		Sprite.flip_h = true
	elif velocity.x < 0:
		Sprite.flip_h = false
	
	check_for_death()
	check_collision()
	move_and_slide()
	
func check_for_death():
	if health <= 0:
		await get_tree().create_timer(1).timeout
		var new_heart = heart.instantiate()
		new_heart.global_position = global_position
		add_sibling(new_heart)
		var new_score = score.instantiate()
		new_score.global_position = global_position
		Playerstats.scorenum = score_value
		add_sibling(new_score)
		Playerstats.score += score_value
		queue_free()
	
func take_damage(dmg):
	health -= dmg
