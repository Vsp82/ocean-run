extends Area2D

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		print("you died from fall damage")
		body.call("take_damage")
