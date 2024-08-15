extends Area2D

const collide = preload("res://Scenes/Characters, weapons and collectables/bullet_1_collision.tscn")
const number = preload("res://Scenes/Other/DamageE_numbers.tscn")
@export var SPEED = 1300
@onready var light = $Light
var damage = 4

func _ready():
	Playerstats.bullets_shot += 1

func _process(delta):
	translate(Vector2.RIGHT.rotated(rotation) * SPEED * delta)
	if light.energy > 0:
		light.energy -= 4

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
	elif body.is_in_group("Button") and body.has_method("pressed"):
		body.pressed()
	elif body.is_in_group("Prop") and body.has_method("damage"):
		body.damage(damage)
	queue_free()
	var new_collide = collide.instantiate()
	new_collide.global_position=global_position
	new_collide.global_rotation=global_rotation+90
	add_sibling(new_collide)
