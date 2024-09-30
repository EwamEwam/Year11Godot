extends Area2D

@export var SPEED :float = 700.0
var damage :int = 3
const particle :PackedScene = preload("res://Scenes/Other/Shooting_Particle.tscn")
@onready var player :Node = get_tree().get_first_node_in_group("Player")
var in_player :bool = false

var entered_player = false
var particle_m = 1

func _ready() -> void:
	pass

func _process(delta) -> void:
	if not in_player:
		translate(Vector2.RIGHT.rotated(rotation) * SPEED * delta)

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_body_entered(body) -> void:
	if body.is_in_group("Player") and body.has_method("damage_player") and not entered_player:
		entered_player = true
		body.damage_player(damage - Playerstats.defence)
		body.shake(damage * 2,0.025,damage * 2,1.2)
		await get_tree().create_timer(0.025).timeout
		in_player = true
		var offset :Vector2 = Vector2(global_position.x - Playerstats.player_x,global_position.y - Playerstats.player_y) 
		for i in range(75):
			global_position  = player.global_position + offset
			await get_tree().create_timer(0.025).timeout
		for i in range(50):
			global_position = player.global_position + offset
			modulate.a -= 0.02
			await get_tree().create_timer(0.025).timeout
		queue_free()
			
	elif body.is_in_group("Prop") and body.has_method("damage"):
		body.damage(damage)
		queue_free()
	if not body.is_in_group("Enemy") and not body.is_in_group("Player"):
		queue_free()
		
func _on_timer_timeout() -> void:
	if not in_player:
		var new_particle :Node = particle.instantiate()
		new_particle.global_position = global_position
		new_particle.set_direction(rotation)
		add_sibling(new_particle)
		$Timer.start(0.05 * particle_m)

func set_power(speed,dam, part) -> void:
	damage = dam
	SPEED = speed
	particle_m = part
