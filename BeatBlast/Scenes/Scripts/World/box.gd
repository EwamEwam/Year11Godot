extends StaticBody2D

@export var health = 10
@onready var sprite = $Crate

func damage(val):
	health -= val
	if health < 1:
		queue_free()
	else:
		sprite.modulate = Color(1.1,1.1,1.1,1)
		await get_tree().create_timer(0.25).timeout
		sprite.modulate = Color(1,1,1,1)
