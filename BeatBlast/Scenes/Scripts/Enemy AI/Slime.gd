extends CharacterBody2D

const SPEED = 275.0
const ACCELLERATION = 20.0
const FRICTION = 3.0
var score_value = 10
@onready var Sprite = $Slime_sprite
@onready var animation = $AnimationPlayer
@onready var player = get_tree().get_first_node_in_group("Player")
const heart = preload("res://Scenes/Characters, weapons and collectables/heart5.tscn")
const score = preload("res://Scenes/Other/Score_numbers.tscn")
@export var health = 7
@onready var timer = $hurttimer
@onready var hitbox = $hitbox
@export var damage = 3
@onready var hurtbox = $hurtbox
@onready var circle = $Movement_circle
@onready var Raycast = $RayCast2D
@onready var health_bar = $Health_Metre

enum state {Right, Left, Hurt, Death}
var current_state = state.Right
var animation_can_play = true
var dead = false
@export var max_health = 7

func _ready():
	Sprite.modulate = Color(0.7, 0.7, 0.7, 0.95)

func check_collision():
	if not timer.is_stopped() or health < 1:
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if collision.is_in_group("Player") and timer.is_stopped() and collision.has_method("damage_player"):
				collision.shake(5,0.05,3,1.2)
				collision.damage_player(damage-Playerstats.defence)
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
					velocity = velocity.move_toward(direction_to_player * SPEED, ACCELLERATION)
				else:
					velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
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
		state.Right:
			animation.play("Movement_Right")
		state.Left:
			animation.play("Movement_Left")
		state.Hurt:
			animation.play("Hurt")
		state.Death:
			animation.play("Death")
	
func check_for_death():
	if health <= 0:
		dead = true
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
		
func take_damage(dmg):
	health -= dmg
	if health > 0:
		animation_can_play = false
		current_state = state.Hurt
		Sprite.modulate = Color(1, 1 ,1, 0.75)
		await get_tree().create_timer(0.15).timeout
		Sprite.modulate = Color(0.7, 0.7 , 0.7, 0.95)
		animation_can_play = true

func update_health_bar():
	health_bar.max_value = max_health
	health_bar.value = health
	if health != max_health:
		health_bar.visible = true
	else:
		health_bar.visible = false
