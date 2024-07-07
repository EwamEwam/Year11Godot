extends Node2D

@onready var number = $number
@onready var number_s = $AnimationPlayer

func _ready():
	set_animation(Playerstats.dampval)
	global_position=global_position + Vector2(randf_range(-10,10),randf_range(-10,10))
	
func set_animation(val):
	number_s.play(var_to_str(val))
