extends StaticBody2D

@export var health = 1
@onready var sprite = $Pot
@export var gem1_drop = 1
@export var gem5_drop = 1
var destroyed = false
const gem1 = preload("res://Scenes/Characters, weapons and collectables/gem_1.tscn")
const gem5 = preload("res://Scenes/Characters, weapons and collectables/gem_5.tscn")
const particle = preload("res://Scenes/Other/Pot_Particle.tscn")

func ready():
	sprite.modulate = Color(0.9,0.9,0.9,1)

#Can't just queue_free() as soon as the pot is broken or else the sound won't play
func damage(val):
	health -= val
	if health < 1 and not destroyed:
		$Smash.pitch_scale = randf_range(0.8,1.2)
		$Smash.play()
		destroyed = true
		visible = false
		$Hitbox.queue_free()
		for i in range(gem1_drop):
			var new_gem = gem1.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)
		for i in range(gem5_drop):
			var new_gem = gem5.instantiate()
			new_gem.global_position = global_position
			add_sibling(new_gem)
		for i in range(6):
			var new_particle = particle.instantiate()
			new_particle.global_position = global_position
			add_sibling(new_particle)
		await get_tree().create_timer(1.5).timeout
		queue_free()
	elif health > 0:
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
