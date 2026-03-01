extends Button

@export var startscene: PackedScene

func _on_pressed() -> void:
	get_tree().change_scene_to_packed(startscene)
