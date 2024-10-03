extends Node2D
#Number that comes from a recently killed enemy showing how much score you got. Uses a variable in the playerstats script.
@onready var number = $number
@onready var number_s = $AnimationPlayer

func _ready():
	number_s.play("0")
	set_animation(Playerstats.scorenum)
	global_position=global_position + Vector2(randf_range(-10,10),randf_range(-10,10))
	
func set_animation(val):
	number_s.play(var_to_str(val))
