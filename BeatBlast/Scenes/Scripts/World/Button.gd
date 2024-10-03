extends StaticBody2D
#It has a function when the player shoots it, making it set a value in the playerstats script.
@onready var button = $Button
@export var id = 1

var is_preseed = false

func pressed():
	Playerstats.door_open = id
	if not is_preseed:
		is_preseed = true
		button.play("Pressed")
		
