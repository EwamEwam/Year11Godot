extends Area2D

const number = preload("res://Scenes/Other/DamageE_numbers.tscn")
var damage = 3

func _ready():
	await get_tree().create_timer(0.15).timeout
	queue_free()

func _process(delta):
	pass
	
func _on_body_entered(body):
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage+Playerstats.attack)
		var new_number = number.instantiate()
		new_number.global_position = global_position
		Playerstats.damval=damage+Playerstats.attack
		add_sibling(new_number)
		await get_tree().create_timer(0.05).timeout
		queue_free()
	elif body.is_in_group("Button") and body.has_method("pressed"):
		body.pressed()
	elif body.is_in_group("Prop") and body.has_method("damage"):
		body.damage(damage+Playerstats.attack)
	
