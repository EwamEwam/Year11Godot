extends StaticBody2D

@onready var button = $Button
@export var id = 1

var is_preseed = false

func pressed():
	Playerstats.door_open = id
	if not is_preseed:
		is_preseed = true
		button.play("Pressed")
		
