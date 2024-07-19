extends Area2D

const collide = preload("res://Scenes/Characters, weapons and collectables/bullet_2_collision.tscn")
const number = preload("res://Scenes/Other/DamageE_numbers.tscn")
@export var SPEED = 850
var damage = 2

func _ready():
	rotate(deg_to_rad(randf_range(-6,6)))
	Playerstats.bullets_shot += 1

func _process(delta):
	translate(Vector2.RIGHT.rotated(rotation) * SPEED * delta)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
func _on_body_entered(body):
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
		var new_number = number.instantiate()
		new_number.global_position = global_position
		Playerstats.damval=damage
		add_sibling(new_number)
		Playerstats.bullets_hit += 1
	queue_free()
	var new_collide = collide.instantiate()
	new_collide.global_position=global_position
	new_collide.global_rotation=global_rotation+90
	add_sibling(new_collide)
