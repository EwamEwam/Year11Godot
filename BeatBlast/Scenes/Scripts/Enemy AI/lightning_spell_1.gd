extends Node2D
#Lightning spell, works the same as the bullet but also gives the player the blocked status effect
const Speed = 800.0
var Damage = 11
@onready var light = $PointLight2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	translate(Vector2.RIGHT.rotated(rotation) * Speed * delta)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_method("damage_player"):
		body.damage_player(Damage-Playerstats.defence)
		body.shake(18,0.025,18,1.2)
		body.blocked(4)
	if not body.is_in_group("Enemy"):
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
