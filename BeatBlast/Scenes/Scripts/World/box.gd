extends StaticBody2D

@export var health = 10
@onready var sprite = $Crate
@export var drop = 0
var destroyed = false
const heart5 = preload("res://Scenes/Characters, weapons and collectables/heart5.tscn")
const heart1 = preload("res://Scenes/Characters, weapons and collectables/heart1.tscn")
const heart40 = preload("res://Scenes/Characters, weapons and collectables/heart40.tscn")
const heart10 = preload("res://Scenes/Characters, weapons and collectables/heart10.tscn")

func ready():
	sprite.modulate = Color(0.9,0.9,0.9,1)

#1 - 5 heart, 2 - 1 heart, 3 - 40 heart, 4 - 10 heart 
func damage(val):
	health -= val
	if health < 1 and not destroyed:
		destroyed = true
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
			4:
				var new_heart = heart10.instantiate()
				new_heart.global_position = global_position
				add_sibling(new_heart)
	else:
		sprite.modulate = Color(1,1,1,1)
		shake()
		await get_tree().create_timer(0.2).timeout
		sprite.modulate = Color(0.9,0.9,0.9,1)
		
func shake():
	var offset_x = 0
	var offset_y = 0
	for i in range(4):
		offset_x = randf_range(-4,4)
		offset_y = randf_range(-4,4)
		sprite.position.x = 0 + offset_x
		sprite.position.y = 0 + offset_y
		await get_tree().create_timer(0.025).timeout
	sprite.position.x = 0
	sprite.position.y = 0
