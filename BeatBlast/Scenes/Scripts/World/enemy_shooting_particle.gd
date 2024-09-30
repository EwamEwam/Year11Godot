extends Node2D

@onready var sprite = $Particle_sprite
var SPEED = 7.5

func _ready() -> void:
	SPEED += randf_range(-0.5,0.5)
	look_at(Vector2(Playerstats.player_x,Playerstats.player_y))
	rotate(deg_to_rad(randf_range(-25,25)))
	SPEED *= randf_range(0.9,1.1)
	
func _physics_process(delta: float) -> void:
	sprite.modulate.a -= 0.04
	if sprite.modulate.a <= 0:
		queue_free()
	sprite.rotate(0.1)
	translate(Vector2.RIGHT.rotated(rotation) * SPEED)
	SPEED /= 1.04
