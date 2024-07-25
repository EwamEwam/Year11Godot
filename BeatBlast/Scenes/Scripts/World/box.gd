extends StaticBody2D

@export var health = 10
@onready var sprite = $Crate
@onready var drop = 0
const heart5 = preload("res://Scenes/Characters, weapons and collectables/heart5.tscn")

func damage(val):
	health -= val
	if health < 1:
		queue_free()
	else:
		sprite.modulate = Color(1.1,1.1,1.1,1)
		await get_tree().create_timer(0.25).timeout
		sprite.modulate = Color(1,1,1,1)
		match drop:
			0:
				pass
			1:
				var new_heart = heart5.instantiate()
				new_heart.global_position = global_position
				add_sibling(new_heart)
