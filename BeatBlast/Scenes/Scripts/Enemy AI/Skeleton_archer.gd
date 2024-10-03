extends CharacterBody2D
#The archer enemy, I coded this too long ago that I forgot how this works. From a bit of skim reading though I can atleast make a 
#guess. It hasa timer which when it goes off, it checks if the player is in it's inner radius, if it is, it goes into shoot mode where
#it pulls back on it bow and increases it power value until it detects the player is no longer in it's radius or it reachs power level 4.
const SPEED = 225.0
const ACCELLERATION = 25.0
const FRICTION = 5.5
var score_value = 50
@onready var Sprite = $Skeleton_Sprite
@onready var animation = $AnimationPlayer
@onready var onscreen = $VisibleOnScreenNotifier2D
@onready var player = get_tree().get_first_node_in_group("Player")
const arrow = preload("res://Scenes/Enemies/Arrow.tscn")
const particle = preload("res://Scenes/Other/Bone_Particle.tscn")
@export var health = 28
@export var max_health = 28
@onready var timer = $Hurt_Timer
@onready var hitbox = $hitbox
@onready var shoot_timer = $Shoot_Timer
@export var damage = 6
@onready var hurtbox = $Hurtbox
@onready var circle = $Player_Detection_Range
@onready var Too_Close_Circle = $PLayer_Too_Close_Range
@onready var Raycast = $RayCast2D
@onready var health_bar = $Health_metre

enum state {Idle, Walking, Pull_back_, Shoot, Hurt, Death}
enum direction {Left, Right}
var current_state = state.Idle
var current_direction = direction.Left
var power = 0
var can_move = true
var dead = false

var animation_can_play = true
var shooting = false

func _ready() -> void:
	Sprite.modulate = Color(0.9,0.9,0.9,1)
	hitbox.disabled = false
	update_health_bar()

func check_collision():
	if not timer.is_stopped() or health < 1:
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if timer.is_stopped():
				collision.shake(16,0.025,16,1.2)
				collision.damage_player(damage-Playerstats.defence)
				timer.start()
				
func _physics_process(delta):
	if onscreen.is_on_screen():
		Raycast.target_position.x = Playerstats.player_x - global_position.x
		Raycast.target_position.y = Playerstats.player_y - global_position.y
		
		if health > 0: 
			var too_close = Too_Close_Circle.get_overlapping_bodies()
			var in_circle = circle.get_overlapping_bodies()
			can_move = true
			var slowed_down = false
			if too_close:
				for collision in too_close:
					if collision.is_in_group("Player"):
						check_collision()
						update_health_bar()
						can_move = false
			if in_circle:
				for collision in in_circle:
					if not Raycast.is_colliding() and can_move and power == 0:
						var direction_to_player = global_position.direction_to(player.global_position)
						velocity = velocity.move_toward(direction_to_player * SPEED, ACCELLERATION)
					elif not collision == self and not slowed_down:
						slowed_down = true
						velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		else:
			velocity = Vector2.ZERO
		
		update_state()
		play_animations()
		update_health_bar()
		move_and_slide()
		
	if current_state == state.Walking:
		animation.speed_scale = clampf(velocity.length()/200, 0.25, 3)
	else:
		animation.speed_scale = 1
	

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
		for i in range(10):
			var new_particle = particle.instantiate()
			new_particle.global_position = global_position
			add_sibling(new_particle)
		var new_heart = heart.instantiate()
		new_heart.global_position = global_position
		add_sibling(new_heart)
		Playerstats.scorenum = score_value
		var new_score = score.instantiate()
		new_score.global_position = global_position
		add_sibling(new_score)
		Playerstats.score += score_value
		Playerstats.enemies_defeated += 1
		for i in range(randi_range(4,6)):
			var new_gem = gem1.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)
		for i in range(randi_range(3,4)):
			var new_gem = gem5.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)

func take_damage(dmg):
	health -= dmg
	call_deferred("check_for_death")
	if health > 0:
		if not shooting:
			animation_can_play = false
			current_state = state.Hurt
		Sprite.modulate = Color(1.1,1.1,1.1,1)
		await get_tree().create_timer(0.15).timeout
		Sprite.modulate = Color(0.9,0.9,0.9,1)
		if not shooting:
			animation_can_play = true

func _on_shoot_timer_timeout():
	var too_close = Too_Close_Circle.get_overlapping_bodies()
	var player_detected = false
	if too_close:
		for collision in too_close:
			if collision.is_in_group("Player") and not Raycast.is_colliding() and health > 0 and is_instance_valid(self):
				shooting = true
				player_detected = true
				animation_can_play = false
				current_state = state.Pull_back_
				if power < 4:
					power += 1
				elif power == 4:
					shoot_arrow(power)
	if not player_detected and power > 0:
		shoot_arrow(power)
	shoot_timer.start(0.7)

func update_health_bar():
	health_bar.max_value = max_health
	health_bar.value = health
	if health != max_health:
		health_bar.visible = true
	else:
		health_bar.visible = false

func shoot_arrow(val):
	if health > 0:
		animation_can_play = false
		current_state = state.Shoot
		power = 0
		var new_arrow = arrow.instantiate()
		new_arrow.global_position = global_position
		new_arrow.look_at(Vector2(Playerstats.player_x,Playerstats.player_y))
		match val:
			1:
				new_arrow.set_power(600,3,1)
			2:
				new_arrow.set_power(750,7,0.8)
			3: 
				new_arrow.set_power(875,11,0.6)
			4:
				new_arrow.set_power(1000,15,0.4)
		add_sibling(new_arrow)
		await get_tree().create_timer(0.25).timeout
		animation_can_play = true
		shooting = false
		
func update_state():
	if animation_can_play:
		if abs(velocity) > Vector2.ZERO:
			current_state = state.Walking
		else:
			current_state = state.Idle
		
	if Playerstats.player_x > global_position.x and health > 0:
		Sprite.flip_h = true
		Sprite.offset.x = -5
		$Shadow.position.x = -25
	elif health > 0:
		Sprite.flip_h = false
		Sprite.offset.x = 5
		$Shadow.position.x = 0
		
func play_animations():
	match current_state:
		state.Idle:
			animation.play("Idle")
		state.Walking:
			animation.play("Walk")
		state.Pull_back_:
			animation.play("Pull_back_" + str(power))
		state.Hurt:
			animation.play("Hurt")
		state.Death:
			animation.play("Death")
		state.Shoot:
			animation.play("Shoot")
