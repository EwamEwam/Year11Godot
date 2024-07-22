extends Node2D

@onready var press = get_tree().get_first_node_in_group("Button")
@export var id = 1

func _physics_process(delta):
	if Playerstats.door_open == id:
		queue_free()
		Playerstats.door_open = 0
