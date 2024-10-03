extends Node2D
#Bone particle for when the archer dies. Uses essentially the same script as most of the other particles
@onready var sprite = $Sprite
var rotation_speed = 10
var x_velocity = 0

func _ready() -> void:
	global_position.y += randi_range(-150,150)
	global_position.x += randi_range(-75,75)
	sprite.rotation_degrees = randi_range(0,360)
	rotation_speed += randf_range(-6,6)
	x_velocity = randf_range(-5,5)
	$AnimationPlayer.play(str(randi_range(1,3)))
	
func _physics_process(delta: float) -> void:
	sprite.rotate(deg_to_rad(rotation_speed))
	sprite.position.x += x_velocity
