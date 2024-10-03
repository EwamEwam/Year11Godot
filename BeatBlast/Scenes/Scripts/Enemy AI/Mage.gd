extends CharacterBody2D
#The mage enemy. has a timer which when it goes off, plays a sick animation with a call method track. Along the animation it calls a function which makes a spell and then the timer resets.
const SPEED = 215.0
const ACCELLERATION = 25.5
const FRICTION = 6.0
var score_value = 50
@onready var Sprite = $Mage_Sprite
@onready var animation = $AnimationPlayer
@onready var onscreen = $VisibleOnScreenNotifier2D
@onready var player = get_tree().get_first_node_in_group("Player")
const heart = preload("res://Scenes/Characters, weapons and collectables/heart10.tscn")
const score = preload("res://Scenes/Other/Score_numbers.tscn")
const lightning = preload("res://Scenes/Enemies/lightning_spell_1.tscn")
const fire = preload("res://Scenes/Enemies/Fire_spell_1.tscn")
const poison = preload("res://Scenes/Enemies/Poison_spell_1.tscn")
const gem1 = preload("res://Scenes/Characters, weapons and collectables/gem_1.tscn")
const gem5 = preload("res://Scenes/Characters, weapons and collectables/gem_5.tscn")
@export var health = 25
@export var max_health = 25
@onready var timer = $Hurt_Timer
@onready var hitbox = $hitbox
@onready var shoot_timer = $Shoot_Timer
@export var damage = 6
@onready var hurtbox = $Hurtbox
@onready var circle = $Player_Detection_Range
@onready var Too_Close_Circle = $PLayer_Too_Close_Range
@onready var Raycast = $RayCast2D
@onready var health_bar = $Health_metre

enum state {Idle,Walking,Attacking,Hurt,Death}
var current_state = state.Idle
var dead = false
var animation_can_play = true

func _ready() -> void:
	Sprite.modulate = Color(0.9,0.9,0.9,1)
	update_health_bar()

func check_collision():
	if not timer.is_stopped() or health < 1:
		return
	var collisions = hurtbox.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if collision.is_in_group("Player") and timer.is_stopped():
				collision.shake(14,0.025,14,1.2)
				collision.damage_player(damage-Playerstats.defence)
				timer.start()
				
func _physics_process(delta):
	if onscreen.is_on_screen():
		Raycast.target_position.x = Playerstats.player_x - global_position.x
		Raycast.target_position.y = Playerstats.player_y - global_position.y
	
		if health > 0: 
			var can_move = true
			var slowed_down = false
			var too_close = Too_Close_Circle.get_overlapping_bodies()
			var in_circle = circle.get_overlapping_bodies()
			if too_close:
				for collision in too_close:
					if collision.is_in_group("Player"):
						check_collision()
						update_health_bar()
						can_move = false
			if in_circle:
				for collision in in_circle:
					if collision.is_in_group("Player") and not Raycast.is_colliding() and can_move and animation_can_play:
						var direction_to_player = global_position.direction_to(player.global_position)
						velocity = velocity.move_toward(direction_to_player * SPEED, ACCELLERATION)
					elif not collision.is_in_group("Enemy") and not collision == self and not slowed_down:
						slowed_down = true
						velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
			else:
				velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		else:
			velocity = Vector2.ZERO
		
		check_for_death()
		update_health_bar()
		move_and_slide()
		update_status()
		play_animation()
		
		if velocity .x > 0:
			Sprite.flip_h = true
		elif velocity.x < 0:
			Sprite.flip_h = false
	
	if animation_can_play and current_state == state.Walking:
		animation.speed_scale = clampf(velocity.length()/200,0.1,1.25)
	
	
func check_for_death():
	if health <= 0:
		dead = true
		current_state = state.Death
		animation_can_play = false
		hitbox.disabled = true
		z_index = -1
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
	if animation_can_play and not current_state == state.Attacking:
		animation_can_play = false
		current_state = state.Hurt
	Sprite.modulate = Color(1.1,1.1,1.1,1)
	await get_tree().create_timer(0.15).timeout
	Sprite.modulate = Color(0.9,0.9,0.9,1)
	if health > 0 and not current_state == state.Attacking:
		animation_can_play = true

func _on_shoot_timer_timeout():
	var in_circle = circle.get_overlapping_bodies()
	if in_circle:
		for collision in in_circle:
			if collision.is_in_group("Player") and not Raycast.is_colliding() and health > 0 and is_instance_valid(self):
				animation_can_play = false
				current_state = state.Attacking
	shoot_timer.start(4)

func update_health_bar():
	health_bar.max_value = max_health
	health_bar.value = health
	if health != max_health:
		health_bar.visible = true
	else:
		health_bar.visible = false

func spell():
	match randi_range(1,3):
		1:
			var new_spell = lightning.instantiate()
			new_spell.global_position = $Spell_Spawner.global_position
			new_spell.look_at(Vector2(Playerstats.player_x, Playerstats.player_y))
			add_sibling(new_spell)
		2:
			var new_spell = poison.instantiate()
			new_spell.global_position = $Spell_Spawner.global_position
			new_spell.look_at(Vector2(Playerstats.player_x, Playerstats.player_y))
			add_sibling(new_spell)
		3:
			var new_spell = fire.instantiate()
			new_spell.global_position = $Spell_Spawner.global_position
			new_spell.look_at(Vector2(Playerstats.player_x, Playerstats.player_y))
			add_sibling(new_spell)

func attack_over():
	if health > 0:
		animation_can_play = true
		current_state = state.Idle

func play_animation():
	match current_state:
		state.Idle:
			animation.play("Idle")
		state.Walking:
			animation.play("Walking")
		state.Attacking:
			animation.play("Attack")
		state.Hurt:
			animation.play("Hurt")
		state.Death:
			animation.play("Death")
	if current_state == state.Attacking:
		animation.speed_scale = 1.05
	elif not current_state == state.Walking:
		animation.speed_scale = 1
		
func update_status():
	if Playerstats.player_x > global_position.x and health > 0:
		Sprite.flip_h = true
		$Spell_Spawner.position.x = 76
		$Shadow.position.x = -27
	elif health > 0:
		Sprite.flip_h = false
		$Spell_Spawner.position.x = -76
		$Shadow.position.x = 27
		
	if animation_can_play:
		if abs(velocity) > Vector2.ZERO:
			current_state = state.Walking
		else:
			current_state = state.Idle
