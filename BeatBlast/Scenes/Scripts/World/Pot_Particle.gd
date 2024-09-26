extends Node2D

@onready var sprite = $Sprite
var rotation_speed = 10
var x_velocity = 0

func _ready() -> void:
	global_position.y += randi_range(-75,75)
	global_position.x += randi_range(-75,75)
	sprite.rotation_degrees = randi_range(0,360)
	rotation_speed += randf_range(-6,6)
	x_velocity = randf_range(-5,5)
	$AnimationPlayer.play(str(randi_range(1,6)))
	
func _physics_process(delta: float) -> void:
	sprite.rotate(deg_to_rad(rotation_speed))
	sprite.position.x += x_velocity
