extends CharacterBody2D

const SPEED = 12500
const ACCELLERATION = 20.0
const FRICTION = 4.0
var score_value = 250
@onready var Sprite = $Slime_sprite
@onready var animation = $AnimationPlayer
@onready var hitbox = $hitbox
@onready var onscreen = $VisibleOnScreenNotifier2D
@onready var player = get_tree().get_first_node_in_group("Player")
const heart = preload("res://Scenes/Characters, weapons and collectables/heart40.tscn")
const score = preload("res://Scenes/Other/Score_numbers.tscn")
const gem5 = preload("res://Scenes/Characters, weapons and collectables/gem_5.tscn")
const gem = preload("res://Scenes/Characters, weapons and collectables/gem_1.tscn")
@export var health = 85
@export var max_health = 85
@onready var timer = $hurttimer
@export var damage = 25
@onready var hurtbox = $hurtbox
@onready var circle = $Movement_circle
@onready var Raycast = $RayCast2D
@onready var health_bar = $Health_metre

enum state {Right, Left, Hurt, Death}
var current_state = state.Right
var animation_can_play = true
var dead = false

func _ready() -> void:
	Sprite.modulate = Color(0.8,0.8,0.8,0.9)
	update_health_bar()

func check_collision() -> void:
	if not timer.is_stopped() or health < 1:
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if collision.is_in_group("Player") and timer.is_stopped() and collision.has_method("damage_player"):
				collision.shake(32,0.025,32,1.2)
				collision.damage_player(damage-Playerstats.defence)
				timer.start()
				
func _physics_process(delta):
	if onscreen.is_on_screen():
		Raycast.target_position.x = Playerstats.player_x - global_position.x
		Raycast.target_position.y = Playerstats.player_y - global_position.y
		
		if health > 0:
			var in_circle = circle.get_overlapping_bodies()
			var slowed_down = false
			if in_circle:
				for collision in in_circle:
					if collision.is_in_group("Player") and not Raycast.is_colliding():
						var direction_to_player = global_position.direction_to(player.global_position)
						velocity = velocity.move_toward(direction_to_player * clampf(SPEED/clampf((health/0.9),1,100),210,380), ACCELLERATION)
					elif not collision.is_in_group("Enemy") and not collision == self and not slowed_down:
						slowed_down = true
						velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		else:
			velocity = Vector2.ZERO
		
		if animation_can_play:
			if velocity .x > 0:
				current_state = state.Right
			elif velocity.x < 0:
				current_state = state.Left
			
		if animation_can_play:
			animation.speed_scale = clampf(velocity.length()/60, 0.5, 15)
		else:
			animation.speed_scale = 1
		
		check_collision()
		animation_play()
		update_health_bar()
		move_and_slide()
		
	else:
		set_process(false)
		
	if not dead:
		check_for_death()
	
func animation_play():
	match current_state:
		state.Right:
			animation.play("Right")
		state.Left:
			animation.play("Left")
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
		await get_tree().create_timer(0.8).timeout
		var new_heart = heart.instantiate()
		new_heart.global_position = global_position
		add_sibling(new_heart)
		Playerstats.scorenum = score_value
		var new_score = score.instantiate()
		new_score.global_position = global_position
		add_sibling(new_score)
		Playerstats.score += score_value
		Playerstats.enemies_defeated += 1
		for i in range(randi_range(8,10)):
			var new_gem = gem.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)
		for i in range(randi_range(8,9)):
			var new_gem = gem5.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)
	
func take_damage(dmg):
	health -= dmg
	if health > 0:
		animation_can_play = false
		current_state = state.Hurt
		Sprite.modulate = Color(1, 1 ,1, 0.9)
		await get_tree().create_timer(0.15).timeout
		Sprite.modulate = Color(0.8, 0.8 , 0.8, 0.9)
		animation_can_play = true

func update_health_bar():
	health_bar.max_value = max_health
	health_bar.value = health
	if health != max_health:
		health_bar.visible = true
	else:
		health_bar.visible = false
