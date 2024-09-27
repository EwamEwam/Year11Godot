extends Node2D

@export var id = 1
@export var type = 1
@onready var player_detection = $Area

@onready var player = get_tree().get_first_node_in_group("Player")

var reading = false

func _ready() -> void:
	if type == 1:
		$AnimationPlayer.play("1_Idle")
	else:
		$AnimationPlayer.play("2_Idle")

func _process(delta: float) -> void:
	var collisions = player_detection.get_overlapping_bodies()
	if collisions:
		for collision in collisions:
			if collision.is_in_group("Player") and Input.is_action_just_pressed("Interact") and not reading and not Playerstats.is_paused:
				read_sign(id)
				reading = true
				get_tree().paused = true
			elif collision.is_in_group("Player") and Input.is_action_just_pressed("Interact") and reading and not Playerstats.is_paused:
				get_tree().paused = false
				player.hide_text()
				reading = false
				
func read_sign(text_id):
	var text = TextData.Signs[str(text_id)]
	Playerstats.sign_text = text
	player.show_sign_text()

func _on_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$AnimationPlayer.play(str(type) + "_Enter")

func _on_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		$AnimationPlayer.play(str(type) + "_Exit")
