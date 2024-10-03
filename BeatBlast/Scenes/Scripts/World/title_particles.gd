extends Node2D
#Particles in the main menu, barely noticable.
@onready var sprite = $Particle_sprite
var SPEED: float = 0.45
var rotation_speed = 0.35
var direction = Vector2(-1,1)

func _ready() -> void:
	sprite.modulate.a = 0.5
	direction += Vector2(randf_range(0,0.2),randf_range(-0.2,0))
	sprite.scale *= randf_range(0.9,1.1)
	global_position.x += randf_range(-2,2)
	global_position.y += randf_range(-2,2)

func _physics_process(delta: float) -> void:
	sprite.modulate.a -= 0.0025
	if sprite.modulate.a <= 0:
		queue_free()
	rotate(deg_to_rad(rotation_speed))
	translate(direction * SPEED)
	
func set_direction(val):
	rotation = val
	rotation += deg_to_rad(180)
	rotate(deg_to_rad(randf_range(-25,25)))
