extends Node2D
#Another spell from the mage enemy, it gives the player the poisoned status effect
const Speed = 750.0
var Damage = 5

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	translate(Vector2.RIGHT.rotated(rotation) * Speed * delta)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("damage_player"):
		body.damage_player(Damage-Playerstats.defence)
		body.shake(9,0.025,9,1.2)
		body.poisoned(10)
	if not body.is_in_group("Enemy"):
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
