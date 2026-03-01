extends Area2D

var check := true
var squid_ready = preload(squid_path)
var squid = squid_ready.instantiate()
var one = 1015
var two = 80

const squid_path = "res://Scenes/Squid.tscn"


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if check:
			$"../Squid/Squid4".position = Vector2(949, 34)
			$"../Squid/Squid5".position = Vector2(1015, 80)
			$"../Squid/Squid6".position = Vector2(883, 83)
			check = false
