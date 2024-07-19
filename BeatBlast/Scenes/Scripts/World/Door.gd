extends StaticBody2D

@onready var press = get_tree().get_first_node_in_group("Button")
var id: int = 1

func _ready():
	press.button_pressed.connect(open)

func open():
	queue_free()

func _process(delta):
	pass
