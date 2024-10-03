extends Node2D
#Door. Detects when a value in the playerstats script is equal to it's ID and opens. 
@onready var press = get_tree().get_first_node_in_group("Button")
@export var id = 1
var closed = true

func _physics_process(delta):
	if Playerstats.door_open == id:
		closed = false
		$Door_Sprite.play("Open")
		$Hitbox/CollisionShape2D.position.x = -104
		$Hitbox/CollisionShape2D.scale.x = 0.15
		Playerstats.door_open = 0
		
