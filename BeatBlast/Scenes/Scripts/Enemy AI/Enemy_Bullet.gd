extends Area2D

@export var SPEED :float = 575
var damage :int = 3
const particle :PackedScene = preload("res://Scenes/Other/Shooting_Particle.tscn")

func _ready() -> void:
	pass

func _process(delta) -> void:
	translate(Vector2.RIGHT.rotated(rotation) * SPEED * delta)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_body_entered(body) -> void:
	if body.is_in_group("Player") and body.has_method("damage_player"):
		body.damage_player(damage - Playerstats.defence)
		body.shake(6,0.025,6,1.2)
	elif body.is_in_group("Prop") and body.has_method("damage"):
		body.damage(damage)
		queue_free()
	if not body.is_in_group("Enemy"):
		queue_free()
		
func _on_timer_timeout() -> void:
	var new_particle :Node = particle.instantiate()
	new_particle.global_position = global_position
	new_particle.set_direction(rotation)
	add_sibling(new_particle)
	$Timer.start(0.05)
