extends Area2D

var take_damage := false

# On the spike, emit a signal or just call the player directly
func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		take_damage = true
		while take_damage:
			body.take_damage()  # let the player handle its own damage
			if Global.Health == 0:
				return
			await wait(0.5)

func _on_body_exited(_body) -> void:
	take_damage = false

func wait(seconds: float):
	await get_tree().create_timer(seconds).timeout
