extends TextureProgressBar

var base_rotation: float

func _ready() -> void:
	base_rotation = rotation_degrees

func _on_value_changed(value: float) -> void:
	var dir = 1 if randi() % 2 == 0 else -1
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", base_rotation + 6 * dir, 0.05)
	tween.tween_property(self, "rotation_degrees", base_rotation - 4 * dir, 0.05)
	tween.tween_property(self, "rotation_degrees", base_rotation + 2 * dir, 0.04)
	tween.tween_property(self, "rotation_degrees", base_rotation - 1 * dir, 0.04)
	tween.tween_property(self, "rotation_degrees", base_rotation, 0.03)
