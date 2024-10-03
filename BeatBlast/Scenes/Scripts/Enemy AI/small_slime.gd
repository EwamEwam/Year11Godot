extends CharacterBody2D
#Small slime enemy, Works like the standard slime but instead of dealing damage, it gives the player the Slimed status effect
const SPEED = 225.0
const ACCELLERATION = 18.0
const FRICTION = 4.0
var score_value = 2
@onready var Sprite = $Slime_sprite
@onready var animation = $AnimationPlayer
@onready var onscreen = $VisibleOnScreenNotifier2D
@onready var player = get_tree().get_first_node_in_group("Player")
@export var health = 1
@onready var timer = $hurttimer
@onready var hitbox = $hitbox
@export var damage = 0
@onready var hurtbox = $hurtbox
@onready var circle = $Movement_circle
@onready var Raycast = $RayCast2D

enum state {Right, Left, Hurt, Death}
var current_state = state.Right
var animation_can_play = true
var dead = false
@export var max_health = 1

func _ready():
	Sprite.modulate = Color(0.6, 0.6, 0.6, 0.9)
	hitbox.disabled = false

func check_collision():
	if not timer.is_stopped() or health < 1:
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if timer.is_stopped():
				collision.shake(3,0.025,3,1.4)
				collision.slimed(2)
				timer.start()

func _physics_process(delta) -> void:
	if onscreen.is_on_screen():
		Raycast.target_position.x = Playerstats.player_x - global_position.x
		Raycast.target_position.y = Playerstats.player_y - global_position.y
	
		if health > 0:
			var in_circle = circle.get_overlapping_bodies()
			var slowed_down = false
			if in_circle:
				for collision in in_circle:
					if not Raycast.is_colliding():
						var direction_to_player = global_position.direction_to(player.global_position)
						velocity = velocity.move_toward(direction_to_player * SPEED, ACCELLERATION)
						check_collision()
					elif not collision == self and not slowed_down:
						slowed_down = true
						velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		else:
			velocity = Vector2.ZERO
	
		if animation_can_play:
			animation.speed_scale = clampf(velocity.length()/50, 0.8, 10)
		else:
			animation.speed_scale = 1
			
		change_state()
		animation_play()
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

func check_for_death() -> void:
	if health <= 0 and not dead:
		dead = true
		hitbox.disabled = true
		z_index = -1
		animation_can_play = false
		current_state = state.Death
		var heart = load("res://Scenes/Characters, weapons and collectables/heart1.tscn")
		var score = load("res://Scenes/Other/Score_numbers.tscn")
		var gem1 = load("res://Scenes/Characters, weapons and collectables/gem_1.tscn")
		await get_tree().create_timer(0.75).timeout
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
		
func take_damage(dmg):
	health -= dmg
	call_deferred("check_for_death")
	if health > 0:
		animation_can_play = false
		current_state = state.Hurt
		Sprite.modulate = Color(0.9, 0.9 ,0.9, 0.75)
		await get_tree().create_timer(0.15).timeout
		Sprite.modulate = Color(0.6, 0.6, 0.6, 0.9)
		animation_can_play = true
