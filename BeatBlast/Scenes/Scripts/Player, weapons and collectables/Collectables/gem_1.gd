extends Area2D

@export var value = 1
@export var SPEED = 1000

func _ready():
	rotate(deg_to_rad(randf_range(0,360)))
	
func _physics_process(delta):
	if SPEED > 0:
		translate(Vector2.RIGHT.rotated(rotation) * SPEED * delta)
		SPEED /= 1.25
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		Playerstats.gemsval = 1
		Playerstats.gems += value
		queue_free()
