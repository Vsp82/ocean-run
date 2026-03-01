extends Button

@export var playascene: PackedScene

func _on_pressed() -> void:
	print(playascene)
	if playascene:
		Global.score = 0
		Global.realscore = 0
		Global.run_time = 0
		get_tree().change_scene_to_packed(playascene)		
	else:
		print("Scene not assigned!")
