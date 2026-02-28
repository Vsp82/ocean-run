extends CheckButton

func _ready() -> void:
	button_pressed = Global.rumble_enabled
	toggled.connect(_on_toggled)

func _on_toggled(pressed1: bool) -> void:
	Global.save_rumble(pressed1)
