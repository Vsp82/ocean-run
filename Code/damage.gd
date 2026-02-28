extends Area2D

func _on_body_entered(body: CharacterBody2D) -> void:
    if body.is_in_group("Player"):
        body.take_damage()

func _on_body_exited(body: CharacterBody2D) -> void:
    pass