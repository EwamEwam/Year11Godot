extends StaticBody2D

@onready var button = $Button
@onready var input = $Input
@export var id = 1

func _ready():
	pass

func pressed():
	Playerstats.door_open = id
	queue_free()
