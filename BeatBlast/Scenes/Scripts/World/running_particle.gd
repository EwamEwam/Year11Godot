extends Node2D

@onready var sprite :Node = $Particle_sprite
@onready var player = get_tree().get_first_node_in_group("Player")
var SPEED :float = 1.8

func _ready() -> void:
	var color :Color = get_colour()
	sprite.modulate = color
	sprite.modulate.a = 0.8
	global_position.x += randf_range(-25,25)
	global_position.y += randf_range(-25,25)
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
	rotate(deg_to_rad(randf_range(-30,30)))

#gets the colour of the pixel underneath the player and returns it.
func get_colour() -> Color:
	var image: Image = get_viewport().get_texture().get_image()
	var view_size: Vector2 = get_viewport().get_texture().get_size()
	var target_pixel: Vector2 = Vector2((view_size.x - Playerstats.camera_drag.x)/2, (view_size.y - Playerstats.camera_drag.y)/1.649)
	var color: Color = image.get_pixelv(target_pixel - player.camera_offset)
	return color
