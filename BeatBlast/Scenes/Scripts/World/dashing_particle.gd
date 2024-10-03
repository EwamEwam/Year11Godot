extends Node2D
#Particle that generates when the player dash, I can't think of anything else to say
@onready var sprite :Node = $Particle_sprite
@onready var player = get_tree().get_first_node_in_group("Player")
var SPEED :float = 7.5

func _ready() -> void:
	sprite.modulate.a = 0.64
	global_position.x += randf_range(-50,50)
	global_position.y += randf_range(-200,200)
	if randi_range(0,2) == 0:
		sprite.play("Small")

func _physics_process(delta: float) -> void:
	sprite.modulate.a -= 0.04
	if sprite.modulate.a <= 0:
		queue_free()
	sprite.rotate(0.1)
	translate(Vector2.RIGHT.rotated(rotation) * SPEED)
	SPEED /= 1.04
	
func set_direction(val):
	rotation = val.angle()
	rotation += deg_to_rad(180)
	rotate(deg_to_rad(randf_range(-60,60)))
