extends Area2D

@export var SPEED = 750
var damage = 3

func _ready() -> void:
	pass

func _process(delta):
	translate(Vector2.RIGHT.rotated(rotation) * SPEED * delta)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("Player") and body.has_method("damage_player"):
		body.damage_player(damage - Playerstats.defence)
		body.shake(5,0.05,4,1.1)
	elif body.is_in_group("Prop") and body.has_method("damage"):
		body.damage(damage)
		queue_free()
	if not body.is_in_group("Enemy"):
		queue_free()
