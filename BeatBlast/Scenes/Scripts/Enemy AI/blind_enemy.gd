extends CharacterBody2D

const SPEED = 350.0
const ACCELLERATION = 25.0
const FRICTION = 3.5
var score_value = 25
@onready var Sprite = $Slime_sprite
@onready var animation = $AnimationPlayer
@onready var onscreen = $VisibleOnScreenNotifier2D
@onready var player = get_tree().get_first_node_in_group("Player")
const heart = preload("res://Scenes/Characters, weapons and collectables/heart5.tscn")
const score = preload("res://Scenes/Other/Score_numbers.tscn")
const gem = preload("res://Scenes/Characters, weapons and collectables/gem_1.tscn")
const gem5 = preload("res://Scenes/Characters, weapons and collectables/gem_5.tscn")
@export var health = 20
@onready var timer = $hurttimer
@onready var movement_timer = $Movement_timer
@onready var hitbox = $hitbox
@export var damage = 12
@onready var hurtbox = $hurtbox
@onready var circle = $Movement_circle
@onready var health_bar = $Health_Metre

var direction = Vector2.ZERO
var setting = false
enum state {Move, Hurt, Death}
var current_state = state.Move
var animation_can_play = true
var dead = false
@export var max_health = 20

func _ready():
	Sprite.modulate = Color(0.7, 0.7, 0.7, 0.9)
	update_health_bar()

func check_collision():
	if not timer.is_stopped() or health < 1:
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if collision.is_in_group("Player") and timer.is_stopped() and collision.has_method("damage_player"):
				collision.shake(12,0.025,12,1.2)
				collision.damage_player(damage-Playerstats.defence)
				timer.start()
				
func _physics_process(delta):
	if onscreen.is_on_screen():
		if health > 0:
			if not movement_timer.is_stopped():
				velocity = velocity.move_toward(direction * SPEED, ACCELLERATION)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		else:
			velocity = Vector2.ZERO
		
		if animation_can_play:
			animation.speed_scale = clampf(velocity.length()/75, 0.75, 9)
		else:
			animation.speed_scale = 1
		
		check_collision()
		change_state()
		animation_play()
		move_and_slide()
		update_health_bar()
		
		if not setting and movement_timer.is_stopped():
			set_direction()
		
	else:
		set_process(false)
			
	if not dead:
		check_for_death()
	
func change_state():
	if animation_can_play:
		if abs(velocity) > Vector2.ZERO:
			current_state = state.Move
	
func animation_play():
	match current_state:
		state.Move:
			animation.play("Move")
		state.Hurt:
			animation.play("Hurt")
		state.Death:
			animation.play("Death")

func check_for_death():
	if health <= 0:
		dead = true
		z_index = -1
		hitbox.disabled = true
		animation_can_play = false
		current_state = state.Death
		await get_tree().create_timer(0.5).timeout
		var new_heart = heart.instantiate()
		new_heart.global_position = global_position
		add_sibling(new_heart)
		Playerstats.scorenum = score_value
		var new_score = score.instantiate()
		new_score.global_position = global_position
		add_sibling(new_score)
		Playerstats.score += score_value
		for i in range(randi_range(10,12)):
			var new_gem = gem.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)
		for i in range(randi_range(11,12)):
			var new_gem = gem5.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)
		queue_free()
		
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
	await get_tree().create_timer(randf_range(0.5,1)).timeout
	direction = Vector2(randf_range(-1,1),randf_range(-1,1))
	movement_timer.start(randf_range(1,4))
	setting = false
