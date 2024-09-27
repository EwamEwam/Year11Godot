extends CharacterBody2D

const SPEED = 180.0
const ACCELLERATION = 25.5
const FRICTION = 6.0
var score_value = 50
@onready var Sprite = $Gun
@onready var onscreen = $VisibleOnScreenNotifier2D
@onready var player = get_tree().get_first_node_in_group("Player")
const heart = preload("res://Scenes/Characters, weapons and collectables/heart10.tscn")
const score = preload("res://Scenes/Other/Score_numbers.tscn")
const lightning = preload("res://Scenes/Enemies/lightning_spell_1.tscn")
const fire = preload("res://Scenes/Enemies/Fire_spell_1.tscn")
const poison = preload("res://Scenes/Enemies/Poison_spell_1.tscn")
const gem1 = preload("res://Scenes/Characters, weapons and collectables/gem_1.tscn")
const gem5 = preload("res://Scenes/Characters, weapons and collectables/gem_5.tscn")
@export var health = 25
@export var max_health = 25
@onready var timer = $Hurt_Timer
@onready var hitbox = $hitbox
@onready var shoot_timer = $Shoot_Timer
@export var damage = 6
@onready var hurtbox = $Hurtbox
@onready var circle = $Player_Detection_Range
@onready var Too_Close_Circle = $PLayer_Too_Close_Range
@onready var Raycast = $RayCast2D
@onready var health_bar = $Health_metre

func check_collision():
	if not timer.is_stopped() or health < 1:
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if collision.is_in_group("Player") and timer.is_stopped() and collision.has_method("damage_player"):
				collision.shake(8,0.025,8,1.2)
				collision.damage_player(damage-Playerstats.defence)
				timer.start()
				
func _physics_process(delta):
	if onscreen.is_on_screen():
		Raycast.target_position.x = Playerstats.player_x - global_position.x
		Raycast.target_position.y = Playerstats.player_y - global_position.y
	
		if health > 0: 
			var can_move = true
			var slowed_down = false
			var too_close = Too_Close_Circle.get_overlapping_bodies()
			var in_circle = circle.get_overlapping_bodies()
			if too_close:
				for collision in too_close:
					if collision.is_in_group("Player"):
						check_collision()
						update_health_bar()
						can_move = false
			if in_circle:
				for collision in in_circle:
					if collision.is_in_group("Player") and not Raycast.is_colliding() and can_move:
						var direction_to_player = global_position.direction_to(player.global_position)
						velocity = velocity.move_toward(direction_to_player * SPEED, ACCELLERATION)
					elif not collision.is_in_group("Enemy") and not collision == self and not slowed_down:
						slowed_down = true
						velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		else:
			velocity = Vector2.ZERO
			
		check_collision()
		check_for_death()
		update_health_bar()
		move_and_slide()
		
		if velocity .x > 0:
			Sprite.flip_h = true
		elif velocity.x < 0:
			Sprite.flip_h = false
	
func check_for_death():
	if health <= 0:
		hitbox.disabled = true
		z_index = -1
		await get_tree().create_timer(1).timeout
		var new_heart = heart.instantiate()
		new_heart.global_position = global_position
		add_sibling(new_heart)
		Playerstats.scorenum = score_value
		var new_score = score.instantiate()
		new_score.global_position = global_position
		add_sibling(new_score)
		Playerstats.score += score_value
		Playerstats.enemies_defeated += 1
		queue_free()
		for i in range(randi_range(7,8)):
			var new_gem = gem1.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)
		for i in range(randi_range(3,4)):
			var new_gem = gem5.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)
			
func take_damage(dmg):
	health -= dmg

func _on_shoot_timer_timeout():
	var in_circle = circle.get_overlapping_bodies()
	if in_circle:
		for collision in in_circle:
			if collision.is_in_group("Player") and not Raycast.is_colliding() and health > 0:
				spell(randi_range(1,3))
	shoot_timer.start(2.75)

func update_health_bar():
	health_bar.max_value = max_health
	health_bar.value = health
	if health != max_health:
		health_bar.visible = true
	else:
		health_bar.visible = false

func spell(type):
	match type:
		1:
			var new_spell = lightning.instantiate()
			new_spell.global_position = global_position
			new_spell.look_at(Vector2(Playerstats.player_x, Playerstats.player_y))
			add_sibling(new_spell)
		2:
			var new_spell = poison.instantiate()
			new_spell.global_position = global_position
			new_spell.look_at(Vector2(Playerstats.player_x, Playerstats.player_y))
			add_sibling(new_spell)
		3:
			var new_spell = fire.instantiate()
			new_spell.global_position = global_position
			new_spell.look_at(Vector2(Playerstats.player_x, Playerstats.player_y))
			add_sibling(new_spell)
