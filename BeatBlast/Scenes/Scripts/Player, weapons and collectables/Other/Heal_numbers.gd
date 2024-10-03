extends Node2D
#Numbers represent the amount of health the player has healed by. Uses a variable in the playerstats scripts and runs the corresponding animation
@onready var number = $number
@onready var number_s = $AnimationPlayer

func _ready():
	set_animation(Playerstats.healnum)
	global_position=global_position + Vector2(randf_range(-10,10),randf_range(-10,10))
	
func set_animation(val):
	number_s.play(var_to_str(val))
