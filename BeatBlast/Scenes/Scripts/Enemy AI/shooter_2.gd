extends CharacterBody2D

const SPEED = 250.0
const ACCELLERATION = 30.0
const FRICTION = 6.0
var score_value = 40
@onready var Sprite = $Sprite_node/Sprite
@onready var onscreen = $VisibleOnScreenNotifier2D
@onready var animation = $AnimationPlayer
@onready var player = get_tree().get_first_node_in_group("Player")
const heart = preload("res://Scenes/Characters, weapons and collectables/heart10.tscn")
const score = preload("res://Scenes/Other/Score_numbers.tscn")
const bullet = preload("res://Scenes/Enemies/enemy_bullet2.tscn")
const gem1 = preload("res://Scenes/Characters, weapons and collectables/gem_1.tscn")
const gem5 = preload("res://Scenes/Characters, weapons and collectables/gem_5.tscn")
const particle = preload("res://Scenes/Other/Shooter_2_Particle.tscn")
const shoot_particle = preload("res://Scenes/Other/Enemy_Shooting_particle.tscn")
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

@onready var world = get_node('/root/level')

enum state {Idle, Shoot, Death}
var animation_can_play = true
var current_state = state.Idle
var time_in_level = 0
var sprite_offset = 0
var dead = false

func _ready() -> void:
	Sprite.modulate = Color(0.7,0.7,0.7,1)
	update_health_bar()

func check_collision():
	if not timer.is_stopped() or health < 1:
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if collision.is_in_group("Player") and timer.is_stopped() and collision.has_method("damage_player"):
				collision.shake(7,0.025,7,1.2)
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
		
		$Sprite_node.position.y = -107 + sprite_offset
		
		if animation_can_play:
			current_state = state.Idle
		
		play_animation()
		check_for_death()
		check_collision()
		update_health_bar()
		move_and_slide()
		
		if Playerstats.player_x > global_position.x and health > 0:
			Sprite.flip_h = true
			$Sprite_node/Bullet_spawner.position.x = 56
		elif health > 0:
			Sprite.flip_h = false
			$Sprite_node/Bullet_spawner.position.x = -56
		
	else:
		set_process(false)
		
func check_for_death():
	if health <= 0 and not dead:
		dead = true
		animation.speed_scale = 2
		current_state = state.Death
		animation_can_play = false
		hitbox.disabled = true
		z_index = -1
		await get_tree().create_timer(0.5).timeout
		var new_heart = heart.instantiate()
		new_heart.global_position = global_position
		add_sibling(new_heart)
		Playerstats.scorenum = score_value
		var new_score = score.instantiate()
		new_score.global_position = global_position
		add_sibling(new_score)
		Playerstats.score += score_value
		Playerstats.enemies_defeated += 1
		for i in range(6):
			var new_particle = particle.instantiate()
			new_particle.global_position = Sprite.global_position
			add_sibling(new_particle)
		for i in range(randi_range(2,3)):
			var new_gem = gem1.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)
		for i in range(randi_range(3,4)):
			var new_gem = gem5.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)

func take_damage(dmg):
	health -= dmg
	animation_can_play = false
	Sprite.modulate = Color(0.9,0.9,0.9,1)
	await get_tree().create_timer(0.15).timeout
	Sprite.modulate = Color(0.7,0.7,0.7,1)
	if health > 0:
		animation_can_play = true

func _on_shoot_timer_timeout():
	if health > 0:
		animation_can_play = false
		current_state = state.Idle
		var in_circle = circle.get_overlapping_bodies()
		if in_circle:
			for collision in in_circle:
				if collision.is_in_group("Player") and not Raycast.is_colliding():
					current_state = state.Shoot
					for i in range(4):
						var new_bullet = bullet.instantiate()
						new_bullet.global_position = $Sprite_node/Bullet_spawner.global_position
						new_bullet.look_at(Vector2(Playerstats.player_x, Playerstats.player_y))
						new_bullet.rotate(deg_to_rad(randf_range(-15,15)))
						add_sibling(new_bullet)
					for i in range(6):
						var new_particle = shoot_particle.instantiate()
						new_particle.global_position = $Sprite_node/Bullet_spawner.global_position
						world.add_child(new_particle)
		shoot_timer.start(2.25)
		await get_tree().create_timer(0.25).timeout
		if health > 0:
			animation_can_play = true

func update_health_bar():
	health_bar.max_value = max_health
	health_bar.value = health
	if health != max_health:
		health_bar.visible = true
	else:
		health_bar.visible = false
	
func _on_stopwatch_timeout() -> void:
	if health > 0:
		time_in_level += 0.017
		sprite_offset = 25 * sin(deg_to_rad(70 * time_in_level))
		
func play_animation():
	match current_state:
		state.Idle:
			animation.play("Idle")
		state.Shoot:
			animation.play("Shoot")
		state.Death:
			animation.speed_scale = 2
			animation.play("Death")
