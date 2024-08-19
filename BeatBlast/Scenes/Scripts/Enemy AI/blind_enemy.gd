extends CharacterBody2D

const SPEED = 200.0
const ACCELLERATION = 15.0
const FRICTION = 2.5
var score_value = 10
@onready var Sprite = $Slime_sprite
@onready var animation = $AnimationPlayer
@onready var player = get_tree().get_first_node_in_group("Player")
const heart = preload("res://Scenes/Characters, weapons and collectables/heart5.tscn")
const score = preload("res://Scenes/Other/Score_numbers.tscn")
const gem = preload("res://Scenes/Characters, weapons and collectables/gem_1.tscn")
@export var health = 20
@onready var timer = $hurttimer
@onready var movement_timer = $Movement_timer
@onready var hitbox = $hitbox
@export var damage = 6
@onready var hurtbox = $hurtbox
@onready var circle = $Movement_circle
@onready var health_bar = $Health_Metre

var direction = Vector2.ZERO
var setting = false
enum state {Right, Left, Hurt, Death}
var current_state = state.Right
var animation_can_play = true
var dead = false
@export var max_health = 20

#sets the slime's colour right for the level
func _ready():
	Sprite.modulate = Color(0.7, 0.7, 0.7, 0.9)

#Checks for any collision and if the player is inside it.
func check_collision():
	if not timer.is_stopped() or health < 1:
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if collision.is_in_group("Player") and timer.is_stopped() and collision.has_method("damage_player"):
				collision.shake(10,0.05,5,1.15)
				collision.damage_player(damage-Playerstats.defence)
				timer.start()
				
func _physics_process(delta):
	if health > 0:
		if not movement_timer.is_stopped():
			velocity = velocity.move_toward(direction * SPEED, ACCELLERATION)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	else:
		velocity = Vector2.ZERO
	
	if animation_can_play:
		animation.speed_scale = clampf(velocity.length()/50, 0.8, 10)
	else:
		animation.speed_scale = 1
	
	if not dead:
		check_for_death()
		
	if not setting and movement_timer.is_stopped():
		set_direction()
		
	update_health_bar()
	change_state()
	animation_play()
	check_collision()
	move_and_slide()
	
func change_state():
	if animation_can_play:
		if velocity.x > 0:
			current_state = state.Right
		elif velocity.x < 0:
			current_state = state.Left
	
func animation_play():
	match current_state:
		pass
		
func check_for_death():
	if health <= 0:
		dead = true
		z_index = -1
		hitbox.disabled = true
		animation_can_play = false
		current_state = state.Death
		await get_tree().create_timer(0.75).timeout
		var new_heart = heart.instantiate()
		new_heart.global_position = global_position
		add_sibling(new_heart)
		Playerstats.scorenum = score_value
		var new_score = score.instantiate()
		new_score.global_position = global_position
		add_sibling(new_score)
		Playerstats.score += score_value
		for i in range(randi_range(3,4)):
			var new_gem = gem.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)
		
func take_damage(dmg):
	health -= dmg
	if health > 0:
		animation_can_play = false
		current_state = state.Hurt
		Sprite.modulate = Color(1, 1 ,1, 0.75)
		await get_tree().create_timer(0.15).timeout
		Sprite.modulate = Color(0.7, 0.7 , 0.7, 0.9)
		animation_can_play = true

func update_health_bar():
	health_bar.max_value = max_health
	health_bar.value = health
	if health != max_health:
		health_bar.visible = true
	else:
		health_bar.visible = false
	
func set_direction() -> void:
	setting = true
	await get_tree().create_timer(randf_range(1.2,4)).timeout
	direction = Vector2(randf_range(-1,1),randf_range(-1,1))
	movement_timer.start(randf_range(1.2,4))
	setting = false
