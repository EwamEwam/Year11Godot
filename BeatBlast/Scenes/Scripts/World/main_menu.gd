extends Node2D

var button_pressed = false

func _ready() -> void:
	pass

func _on_quit_pressed() -> void:
	if not button_pressed:
		get_tree().quit()


func _on_options_pressed() -> void:
	if not button_pressed:
		pass
