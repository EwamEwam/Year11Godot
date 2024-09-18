extends Node2D

@onready var sprite = $Particle_sprite
var SPEED = 3

func _ready() -> void:
	SPEED += randf_range(-0.5,0.5)
	look_at(get_global_mouse_position())
	rotate(deg_to_rad(randf_range(-40,40)))
	SPEED *= randf_range(0.9,1.1)
	if randi() == 1:
		sprite.play("Small")
	
func _physics_process(delta: float) -> void:
	sprite.modulate.a -= 0.04
	if sprite.modulate.a <= 0:
		queue_free()
	sprite.rotate(0.1)
	translate(Vector2.RIGHT.rotated(rotation) * SPEED)
	SPEED /= 1.04
