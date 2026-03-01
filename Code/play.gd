extends Button

@export var playascene: PackedScene

func _on_pressed() -> void:
	print(playascene)
	if playascene:
		get_tree().change_scene_to_packed(playascene)
	else:
		print("Scene not assigned!")
