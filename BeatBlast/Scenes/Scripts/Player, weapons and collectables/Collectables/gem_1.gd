extends Area2D

@export var value = 1
@export var SPEED = 1000
@onready var sprite = $Gem

func _ready():
	sprite.speed_scale += randf_range(-0.1,0.1)
	sprite.modulate = Color(0.7,0.7,0.7,1)
	SPEED += randf_range(-500,300)
	rotate(deg_to_rad(randf_range(0,360)))
	z_index = -1
	
func _physics_process(delta):
	if SPEED > 0.1:
		translate(Vector2.RIGHT.rotated(rotation) * SPEED * delta)
		SPEED /= 1.25
	
func _on_body_entered(body):
	if body.is_in_group("Player"):
		$Animation_Player.speed_scale = 2
		shadow()
		rotation = 0
		$Collision.disabled = true
		Playerstats.gemsval = value
		Playerstats.gems += value
		$Animation_Player.play("Collected")

func shadow():
	for i in range(10):
		await get_tree().create_timer(0.05).timeout
		$Shadow.modulate.a -= 0.1
