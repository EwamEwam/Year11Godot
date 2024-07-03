extends Area2D

@export var SPEED = 850
var damage = 2

func _ready():
	rotate(deg_to_rad(randf_range(-15,15)))

func _process(delta):
	translate(Vector2.RIGHT.rotated(rotation) * SPEED * delta)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
func _on_body_entered(body):
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
