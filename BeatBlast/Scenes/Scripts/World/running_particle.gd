extends Node2D

@onready var sprite = $Particle_sprite
var SPEED = 3

func _ready() -> void:
	var color = get_colour()
	sprite.modulate = color
	sprite.modulate.a = 0.8
	global_position.x += randf_range(-25,25)
	global_position.y += randf_range(-25,25)

func _physics_process(delta: float) -> void:
	sprite.modulate.a -= 0.04
	if sprite.modulate.a <= 0:
		queue_free()
	sprite.rotate(0.1)
	translate(Vector2.RIGHT.rotated(rotation) * SPEED)
	SPEED /= 1.04
	
func set_direction(val):
	rotation = val.angle()
	rotate(deg_to_rad(randf_range(-30,30)))

func get_colour() -> Color:
	var image: Image = get_viewport().get_texture().get_image()
	var color: Color = image.get_pixel(320,289)
	return color
