extends Area2D


func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		if $"../../../Player".No_damage_time_active == false:
			print("damage")
			$"../../../Player".Health -=1
			print($"../../../Player".Health)
			$"../../../Player".No_damage_time.start()
			$"../../../Player".No_damage_time_active = true
			if $"../../../Player".Health == 0:
				print("you died")
				get_tree().reload_current_scene()


func _on_no_damage_time_timeout() -> void:
	$"../../../Player".No_damage_time_active = false
