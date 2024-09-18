extends CharacterBody2D

const SPEED = 30000.0
const ACCELLERATION = 20.0
const FRICTION = 3.0
var score_value = 100
@onready var Sprite = $Ember_Sprite
@onready var animation = $AnimationPlayer
@onready var onscreen = $VisibleOnScreenNotifier2D
@onready var player = get_tree().get_first_node_in_group("Player")
const heart = preload("res://Scenes/Characters, weapons and collectables/heart10.tscn")
const score = preload("res://Scenes/Other/Score_numbers.tscn")
const particle = preload("res://Scenes/Other/fire_particle.tscn")
const gem1 = preload("res://Scenes/Characters, weapons and collectables/gem_1.tscn")
const gem5 = preload("res://Scenes/Characters, weapons and collectables/gem_5.tscn")
@export var health = 42
@onready var timer = $hurttimer
@onready var dashtimer = $Dashtimer
@onready var hitbox = $Hitbox
@export var damage = 8
@onready var hurtbox = $Hurtbox
@onready var circle = $Movement_circle
@onready var Raycast = $RayCast2D
@onready var health_bar = $Health_Metre

enum state {Right, Left, Hurt, Death, Charge, Dash_Right, Dash_Left}
var current_state = state.Right
var animation_can_play = true
var dead = false
@export var max_health = 42

var sprite_offset = 0
var dashing = false
var time_in_level = 0
var particle_timer = 10

func _ready():
	time_in_level = 0
	Sprite.modulate = Color(0.6, 0.6, 0.6, 0.9)

func check_collision():
	if not timer.is_stopped() or health < 1:
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if collision.is_in_group("Player") and timer.is_stopped() and collision.has_method("damage_player"):
				collision.shake(damage * 2.5,0.025,damage * 2.5,1.2)
				collision.burned(floor(damage/3))
				collision.damage_player(damage-Playerstats.defence)
				timer.start()
				
func _physics_process(delta):
	if onscreen.is_on_screen():
		Raycast.target_position.x = Playerstats.player_x - global_position.x
		Raycast.target_position.y = Playerstats.player_y - global_position.y
		
		if health > 0:
			var in_circle = circle.get_overlapping_bodies()
			if in_circle:
				for collision in in_circle:
					if collision.is_in_group("Player") and not Raycast.is_colliding() and dashtimer.is_stopped():
						dash()
						dashtimer.start()
					elif not collision.is_in_group("Enemy"):
						velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		else:
			velocity = Vector2.ZERO
		
		if animation_can_play:
			animation.speed_scale = clampf(velocity.length()/80, 1, 2.5)
		else:
			animation.speed_scale = 1
		
		if velocity == Vector2.ZERO:
			damage = 8
			
		Sprite.position.y = -53 + sprite_offset
			
		check_collision()
		animation_play()
		change_state()
			
	if not dead:
		check_for_death()
		
	update_health_bar()
	move_and_slide()
	
func dash():
	dashing = true
	current_state = state.Charge
	await get_tree().create_timer(0.75).timeout
	damage = 16
	var direction_to_player = global_position.direction_to(player.global_position)
	velocity = velocity.move_toward(direction_to_player * SPEED, ACCELLERATION*80)
	dashing = false
	
func change_state():
	if abs(velocity) > Vector2.ZERO:
		if animation_can_play:
			if velocity.x > 0:
				current_state = state.Dash_Right
			elif velocity.x < 0:
				current_state = state.Dash_Left
	else:
		if current_state == state.Dash_Right:
			current_state = state.Right
		if current_state == state.Dash_Left:
			current_state = state.Left

func animation_play():
	match current_state:
		state.Right:
			animation.play("Right")
		state.Left:
			animation.play("Left")
		state.Dash_Right:
			animation.play("Dash_Right")
		state.Dash_Left:
			animation.play("Dash_Left")
		state.Death:
			animation.play("Death")
		state.Charge:
			animation.play("Charge")
		state.Hurt:
			animation.play("Hurt")
	if current_state == state.Dash_Right:
		Sprite.flip_h = true
	else:
		Sprite.flip_h = false
	
func check_for_death():
	if health <= 0:
		dashing = false
		dead = true
		z_index = -1
		hitbox.disabled = true
		animation_can_play = false
		current_state = state.Death
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
		for i in range(randi_range(10,11)):
			var new_gem = gem1.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)
		for i in range(randi_range(3,4)):
			var new_gem = gem5.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)
		
func take_damage(dmg):
	health -= dmg
	if health > 0:
		if abs(velocity) == Vector2.ZERO:
			animation_can_play = false
			current_state = state.Hurt
		Sprite.modulate = Color(0.9, 0.9 ,0.9, 0.75)
		await get_tree().create_timer(0.15).timeout
		Sprite.modulate = Color(0.6, 0.6 , 0.6, 0.9)
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

func _on_particle_timer_timeout() -> void:
	particle_timer -= clampf(velocity.length()/50,1,6)
	if particle_timer <= 0:
		var new_particle = particle.instantiate()
		new_particle.global_position = global_position
		add_sibling(new_particle)
		particle_timer = randf_range(9,11)
