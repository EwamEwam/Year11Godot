extends CharacterBody2D
#Spider, Like roach but gives the player the poisoned status effect
const SPEED = 400.0
const ACCELLERATION = 20.0
const FRICTION = 3.0
var score_value = 5
@onready var Sprite = $Roach_sprite
@onready var hitbox = $Hitbox
@onready var animation = $AnimationPlayer
@onready var onscreen = $VisibleOnScreenNotifier2D
@onready var player = get_tree().get_first_node_in_group("Player")
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
	hitbox.disabled = false

func check_collision():
	if not timer.is_stopped() or health < 1:
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if timer.is_stopped():
				collision.shake(4,0.025,4,1.35)
				collision.damage_player(damage-Playerstats.defence)
				collision.poisoned(2)
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
					if Raycast.is_colliding()==false:
						var direction_to_player = global_position.direction_to(player.global_position)
						Sprite.look_at(Vector2(Playerstats.player_x, Playerstats.player_y))
						velocity = velocity.move_toward(direction_to_player * SPEED, ACCELLERATION)
						check_collision()
					elif not collision == self and not slowed_down:
						slowed_down = true
						velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		else:
			velocity = Vector2.ZERO
		
		animation_play()
		move_and_slide()
	
	if not dead:
		current_state = state.Running
		animation.speed_scale = velocity.length()/100
	else:
		current_state = state.Death
		animation.speed_scale = 1
	
func animation_play():
	match current_state:
		state.Running:
			animation.play("Running")
		state.Death:
			animation.play("Death")
	
func check_for_death():
	if health <= 0 and not dead:
		dead = true
		hitbox.disabled = true
		current_state = state.Death
		var gem1 = load("res://Scenes/Characters, weapons and collectables/gem_1.tscn")
		var heart = load("res://Scenes/Characters, weapons and collectables/heart1.tscn")
		var score = load("res://Scenes/Other/Score_numbers.tscn")
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
		for i in range(randi_range(2,3)):
			var new_gem = gem1.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)
		queue_free()
		
func take_damage(dmg):
	health -= dmg
	call_deferred("check_for_death")
