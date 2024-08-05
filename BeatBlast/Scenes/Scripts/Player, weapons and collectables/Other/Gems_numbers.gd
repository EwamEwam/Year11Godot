extends Node2D

@onready var number = $number
@onready var number_s = $AnimationPlayer

func _ready():
	set_animation(Playerstats.gemsval)
	
func set_animation(val):
	number_s.play(var_to_str(val))
