extends Node2D

@onready var sprite = $Particle_sprite
var SPEED: float = 3

func _ready() -> void:
	sprite.modulate.a = 0.64
	sprite.scale *= randf_range(0.9,1.1)
	global_position.x += randf_range(-2,2)
	global_position.y += randf_range(-2,2)

func _physics_process(delta: float) -> void:
	sprite.modulate.a -= 0.04
	if sprite.modulate.a <= 0:
		queue_free()
	sprite.rotate(0.1)
	translate(Vector2.RIGHT.rotated(rotation) * SPEED)
	SPEED /= 1.04
	
func set_direction(val):
	rotation = val
	rotation += deg_to_rad(180)
	rotate(deg_to_rad(randf_range(-25,25)))
