extends Node2D
#Don't worry about this (Not like most would probably do in the first place), unfinished / unused grenade mechanic in the game
@onready var sprite = $Sprite
var SPEED = 1000

func _ready() -> void:
	look_at(get_global_mouse_position())
	var distance_to_mouse = get_global_mouse_position() - Vector2(Playerstats.player_x,Playerstats.player_y)
	distance_to_mouse = distance_to_mouse.length()
	SPEED = clampi(distance_to_mouse * 2.5,125,3000)
	
func _process(delta: float) -> void:
	translate(Vector2.RIGHT.rotated(rotation) * SPEED * delta)
	SPEED /= 1.05
