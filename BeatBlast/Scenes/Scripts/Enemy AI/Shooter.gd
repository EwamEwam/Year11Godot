extends CharacterBody2D

const SPEED = 200.0
const ACCELLERATION = 25.0
const FRICTION = 5.5
var score_value = 25
@onready var Sprite = $Gun
@onready var player = get_tree().get_first_node_in_group("Player")
const heart = preload("res://Scenes/Characters, weapons and collectables/heart5.tscn")
const score = preload("res://Scenes/Other/Score_numbers.tscn")
const bullet = preload("res://Scenes/Enemies/enemy_bullet.tscn")
@export var health = 12
@onready var timer = $Hurt_Timer
@onready var shoot_timer = $Shoot_Timer
@export var damage = 1
@onready var hurtbox = $Hurtbox
@onready var circle = $Player_Detection_Range
@onready var Too_Close_Circle = $PLayer_Too_Close_Range
@onready var Raycast = $RayCast2D

func check_collision():
	if not timer.is_stopped() or health < 1:
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if collision.is_in_group("Player") and timer.is_stopped() and collision.has_method("damage_player"):
				collision.shake(2.5,0.05,2,1.3)
				collision.damage_player(damage-Playerstats.defence)
				timer.start()
				
func _physics_process(delta):
	
	Raycast.target_position.x = Playerstats.player_x - global_position.x
	Raycast.target_position.y = Playerstats.player_y - global_position.y
	
	if health > 0: 
		var too_close = Too_Close_Circle.get_overlapping_bodies()
		var in_circle = circle.get_overlapping_bodies()
		if too_close:
			for collision in too_close:
				if collision.is_in_group("Player"):
					check_collision()
					return
		if in_circle:
			for collision in in_circle:
				if collision.is_in_group("Player") and Raycast.is_colliding()==false:
					var direction_to_player = global_position.direction_to(player.global_position)
					velocity = velocity.move_toward(direction_to_player * SPEED, ACCELLERATION)
				else:
					velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
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
		Playerstats.scorenum = score_value
		var new_score = score.instantiate()
		new_score.global_position = global_position
		add_sibling(new_score)
		Playerstats.score += score_value
		queue_free()
		
func take_damage(dmg):
	health -= dmg

func _on_shoot_timer_timeout():
	var in_circle = circle.get_overlapping_bodies()
	if in_circle:
		for collision in in_circle:
			if collision.is_in_group("Player") and Raycast.is_colliding()==false and health > 0:
				var new_bullet = bullet.instantiate()
				new_bullet.global_position = global_position
				new_bullet.look_at(Vector2(Playerstats.player_x, Playerstats.player_y))
				add_sibling(new_bullet)
	shoot_timer.start(1.5)
