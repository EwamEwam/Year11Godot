extends Node2D

@onready var sprite = $Sprite
var rotation_speed = 10
var x_velocity = 0

func _ready() -> void:
	sprite.rotation_degrees = randi_range(0,360)
	rotation_speed += randf_range(-2,2)
	x_velocity = randf_range(-3.5,3.5)
	
func _physics_process(delta: float) -> void:
	sprite.rotate(deg_to_rad(rotation_speed))
	sprite.position.x += x_velocity

func set_type(type):
	if type == 1:
		$AnimationPlayer.play("Shell")
	elif type == 2:
		$AnimationPlayer.play("Shotgun_shell")
