extends Area2D

signal damage

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		damage.emit()
		print("damage")
