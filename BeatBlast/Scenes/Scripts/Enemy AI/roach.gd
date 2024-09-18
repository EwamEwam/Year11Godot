extends CharacterBody2D

const SPEED = 400.0
const ACCELLERATION = 15.0
const FRICTION = 3.0
var score_value = 2
@onready var Sprite = $Roach_sprite
@onready var hitbox = $Hitbox
@onready var animation = $AnimationPlayer
@onready var onscreen = $VisibleOnScreenNotifier2D
@onready var player = get_tree().get_first_node_in_group("Player")
const heart = preload("res://Scenes/Characters, weapons and collectables/heart1.tscn")
const score = preload("res://Scenes/Other/Score_numbers.tscn")
const gem1 = preload("res://Scenes/Characters, weapons and collectables/gem_1.tscn")
@export var health = 1
@onready var timer = $hurttimer
@export var damage = 1
@onready var hurtbox = $Hurtbox
@onready var circle = $Movement_circle
@onready var Raycast = $RayCast2D

enum state {Running, Death}
var current_state = state.Running
var dead = false

func _ready():
	Sprite.rotate(deg_to_rad(randi_range(0,360)))

func check_collision():
	if not timer.is_stopped() or health < 1:
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if collision.is_in_group("Player") and timer.is_stopped() and collision.has_method("damage_player"):
				collision.shake(2,0.025,2,1.5)
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
					if collision.is_in_group("Player") and Raycast.is_colliding()==false:
						var direction_to_player = global_position.direction_to(player.global_position)
						Sprite.look_at(Vector2(Playerstats.player_x, Playerstats.player_y))
						velocity = velocity.move_toward(direction_to_player * SPEED, ACCELLERATION)
					elif not collision.is_in_group("Enemy") and not collision == self and not slowed_down:
						slowed_down = true
						velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		else:
			velocity = Vector2.ZERO
		
		check_collision()
		
	if not dead:
		current_state = state.Running
		animation.speed_scale = velocity.length()/225
		check_for_death()
	else:
		current_state = state.Death
		animation.speed_scale = true
	
	animation_play()
	move_and_slide()
	
func animation_play():
	match current_state:
		state.Running:
			animation.play("Running")
		state.Death:
			animation.play("Death")
	
func check_for_death():
	if health <= 0:
		dead = true
		hitbox.disabled = true
		await get_tree().create_timer(0.7).timeout
		var new_heart = heart.instantiate()
		new_heart.global_position = global_position
		add_sibling(new_heart)
		Playerstats.scorenum = score_value
		var new_score = score.instantiate()
		new_score.global_position = global_position
		add_sibling(new_score)
		Playerstats.score += score_value
		Playerstats.enemies_defeated += 1
		for i in range(randi_range(1,2)):
			var new_gem = gem1.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)
		queue_free()
		
func take_damage(dmg):
	health -= dmg
