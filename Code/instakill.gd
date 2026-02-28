extends Area2D

func _on_body_entered(body) -> void:
	if body.is_in_group("Player"):
		$Timer.start()


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
