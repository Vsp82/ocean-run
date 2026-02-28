extends Area2D

# On the spike, emit a signal or just call the player directly
func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		body.take_damage()  # let the player handle its own damage

func _on_body_exited(body: CharacterBody2D) -> void:
	pass  # probably don't need anything here
