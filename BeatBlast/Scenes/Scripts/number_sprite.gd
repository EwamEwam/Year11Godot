extends Node2D

@onready var number = $number
@onready var number_s = $AnimationPlayer

func _ready():
	number_s.play("2DamageE")
	
func set_animation(val,type):
	pass
	
