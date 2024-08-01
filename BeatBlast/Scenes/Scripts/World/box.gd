extends StaticBody2D

@export var health = 10
@onready var sprite = $Crate
@export var drop = 0
const heart5 = preload("res://Scenes/Characters, weapons and collectables/heart5.tscn")
const heart1 = preload("res://Scenes/Characters, weapons and collectables/heart1.tscn")
const heart40 = preload("res://Scenes/Characters, weapons and collectables/heart40.tscn")

func ready():
	sprite.modulate = Color(0.9,0.9,0.9,1)

func damage(val):
	health -= val
	if health < 1:
		queue_free()
		match drop:
			0:
				pass
			1:
				var new_heart = heart5.instantiate()
				new_heart.global_position = global_position
				add_sibling(new_heart)
			2:
				var new_heart = heart1.instantiate()
				new_heart.global_position = global_position
				add_sibling(new_heart)
			3:
				var new_heart = heart40.instantiate()
				new_heart.global_position = global_position
				add_sibling(new_heart)

	else:
		sprite.modulate = Color(1,1,1,1)
		await get_tree().create_timer(0.25).timeout
		sprite.modulate = Color(0.9,0.9,0.9,1)
