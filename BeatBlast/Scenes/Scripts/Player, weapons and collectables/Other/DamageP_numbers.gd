extends Node2D

@onready var number = $number
@onready var number_s = $AnimationPlayer

func _ready():
	set_animation(Playerstats.damval)
	global_position=global_position + Vector2(randf_range(-10,10),randf_range(-10,10))
	$Hurt.pitch_scale = randf_range(0.75,1.25)
	$Hurt.play()
	
func set_animation(val):
	number_s.play(var_to_str(val))
