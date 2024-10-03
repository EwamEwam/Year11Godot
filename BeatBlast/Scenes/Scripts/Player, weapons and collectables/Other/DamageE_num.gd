extends Node2D
#Number sprite that shows how much damages was down to an enemy. Sets it according to a value in the playerstats script
@onready var number = $number
@onready var number_s = $AnimationPlayer

func _ready():
	set_animation(Playerstats.dampval)
	global_position=global_position + Vector2(randf_range(-10,10),randf_range(-10,10))
	
func set_animation(val):
	number_s.play(var_to_str(val))
