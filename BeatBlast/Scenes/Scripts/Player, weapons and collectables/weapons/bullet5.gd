extends Area2D
#Has some differences to the "bullet" script. Main one being that it keeps track of how many things it has hit and changes it values based on it.
const collide = preload("res://Scenes/Characters, weapons and collectables/bullet_1_collision.tscn")
const number = preload("res://Scenes/Other/DamageE_numbers.tscn")
const particle = preload("res://Scenes/Other/Shooting_Particle.tscn")
@export var SPEED = 1500
var damage = 9
var times_hit = 0

func _ready():
	Playerstats.bullets_shot += 1

func _process(delta):
	translate(Vector2.RIGHT.rotated(rotation) * SPEED * delta)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
func _on_body_entered(body):
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage+Playerstats.attack)
		var new_number = number.instantiate()
		new_number.global_position = global_position
		Playerstats.damval=damage+Playerstats.attack
		add_sibling(new_number)
		if times_hit == 1:
			Playerstats.bullets_hit += 1
		if times_hit != 2:
			damage -= 2
			times_hit += 1
			SPEED -= 300
		else:
			queue_free()
			var new_collide = collide.instantiate()
			new_collide.global_position=global_position
			new_collide.global_rotation=global_rotation+90
			add_sibling(new_collide)

	elif body.is_in_group("Button") and body.has_method("pressed"):
		body.pressed()
	elif body.is_in_group("Prop") and body.has_method("damage"):
		body.damage(damage+Playerstats.attack)
		if times_hit == 1:
			Playerstats.bullets_hit += 1
		if times_hit != 2:
			damage -= 2
			times_hit += 1
			SPEED -= 300
		else:
			queue_free()
			var new_collide = collide.instantiate()
			new_collide.global_position=global_position
			new_collide.global_rotation=global_rotation+90
			add_sibling(new_collide)
	elif not body.is_in_group("Enemy"):
		queue_free()
		var new_collide = collide.instantiate()
		new_collide.global_position=global_position
		new_collide.global_rotation=global_rotation+90
		add_sibling(new_collide)

func _on_timer_timeout() -> void:
	var new_particle = particle.instantiate()
	new_particle.global_position = global_position
	new_particle.set_direction(rotation)
	add_sibling(new_particle)
	$Timer.start(randf_range(0.04,0.06))
