extends Area2D

var damage = 3

func _ready():
	await get_tree().create_timer(0.15).timeout
	queue_free()

func _process(delta):
	pass
	
func _on_body_entered(body):
	if body.is_in_group("Enemy") and body.has_method("take_damage"):
		body.take_damage(damage)
		await get_tree().create_timer(0.05).timeout
		queue_free()
