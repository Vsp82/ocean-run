extends Area2D

var player_in_spike := false
var cbody 


func _process(_delta: float) -> void:
	if player_in_spike:
		if cbody.is_in_group("Player"):
			if $"../../../Player".No_damage_time_active == false:
				print("damage")
				$"../../../Player".Health -=1
				print($"../../../Player".Health)
				$"../../../Player".No_damage_time.start()
				$"../../../Player".No_damage_time_active = true
				if $"../../../Player".Health == 0:
					print("you died")
					get_tree().reload_current_scene()

func _on_body_entered(body: CharacterBody2D) -> void:
	player_in_spike = true
	cbody = body


func _on_no_damage_time_timeout() -> void:
	$"../../../Player".No_damage_time_active = false


func _on_body_exited(body: CharacterBody2D) -> void:
	player_in_spike = false
	cbody = body
