extends CharacterBody2D
#This script is essentially the same as the green slime's except there are changes to the numbers/variables and now it creates two green slimes upon death
const SPEED = 225.0
const ACCELLERATION = 18.0
const FRICTION = 3.5
var score_value = 25
@onready var Sprite = $Slime_sprite
@onready var animation = $AnimationPlayer
@onready var onscreen = $VisibleOnScreenNotifier2D
@onready var player = get_tree().get_first_node_in_group("Player")
@export var health = 16
@onready var timer = $hurttimer
@onready var hitbox = $hitbox
@export var damage = 5
@onready var hurtbox = $hurtbox
@onready var circle = $Movement_circle
@onready var Raycast = $RayCast2D
@onready var health_bar = $Health_metre

enum state {Right, Left, Hurt, Death}
var current_state = state.Right
var animation_can_play = true
var dead = false
@export var max_health = 16

func _ready():
	Sprite.modulate = Color(0.7,0.7,0.7,0.9)
	hitbox.disabled = false
	update_health_bar()

func check_collision():
	if not timer.is_stopped() or health < 1:
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if timer.is_stopped():
				collision.shake(12,0.025,12,1.2)
				collision.damage_player(damage-Playerstats.defence)
				timer.start()
				
func _physics_process(delta):
	if onscreen.is_on_screen():
		Raycast.target_position.x = Playerstats.player_x - global_position.x
		Raycast.target_position.y = Playerstats.player_y - global_position.y
		
		if health > 0:
			var slowed_down = false
			var in_circle = circle.get_overlapping_bodies()
			if in_circle:
				for collision in in_circle:
					if Raycast.is_colliding()==false:
						var direction_to_player = global_position.direction_to(player.global_position)
						velocity = velocity.move_toward(direction_to_player * SPEED, ACCELLERATION)
						check_collision()
					elif not slowed_down and not collision == self:
						slowed_down = true
						velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		else:
			velocity = Vector2.ZERO
		
		if animation_can_play:
			animation.speed_scale = clampf(velocity.length()/70, 0.5, 8)
		else:
			animation.speed_scale = 1
		
		change_state()
		animation_play()
		move_and_slide()
		update_health_bar()
	
func change_state():
	if animation_can_play:
		if velocity.x > 0:
			current_state = state.Right
		elif velocity.x < 0:
			current_state = state.Left
	
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
	if health <= 0 and not dead:
		dead = true
		hitbox.disabled = true
		z_index = -1
		animation_can_play = false
		current_state = state.Death
		var gem1 = load("res://Scenes/Characters, weapons and collectables/gem_1.tscn")
		var gem5 = load("res://Scenes/Characters, weapons and collectables/gem_5.tscn")
		var heart = load("res://Scenes/Characters, weapons and collectables/heart10.tscn")
		var score = load("res://Scenes/Other/Score_numbers.tscn")
		var slime = load("res://Scenes/Enemies/slime.tscn")
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
		for i in range(2):
			var new_slime = slime.instantiate()
			new_slime.global_position = global_position
			new_slime.global_position.x += randf_range(-5,5)
			new_slime.global_position.y += randf_range(-5,5)
			add_sibling(new_slime)
		for i in range(randi_range(4,5)):
			var new_gem = gem1 .instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)
		var new_gem = gem5.instantiate()
		new_gem.global_position = global_position
		add_sibling(new_gem)

func take_damage(dmg):
	health -= dmg
	call_deferred("check_for_death")
	if health > 0:
		animation_can_play = false
		current_state = state.Hurt
		Sprite.modulate = Color(1,1,1,1)
		await get_tree().create_timer(0.15).timeout
		Sprite.modulate = Color(0.7,0.7,0.7,0.9)
		animation_can_play = true

func update_health_bar():
	health_bar.max_value = max_health
	health_bar.value = health
	if health != max_health:
		health_bar.visible = true
	else:
		health_bar.visible = false
