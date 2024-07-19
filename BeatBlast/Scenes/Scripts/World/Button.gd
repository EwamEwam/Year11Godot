extends StaticBody2D

@onready var button = $Button
@onready var input = $Input
var id: int = 1

signal button_pressed

func pressed():
	emit_signal("button_pressed")
	queue_free()
