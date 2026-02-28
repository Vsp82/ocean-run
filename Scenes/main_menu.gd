extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_settings_pressed() -> void:
	$main.visible = false
	$Settings.visible = true


func _on_bak_pressed() -> void:
	$main.visible = true
	$Settings.visible = false
