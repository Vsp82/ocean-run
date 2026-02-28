extends VSlider

func _ready() -> void:
	min_value = -40.0
	max_value = 0.0
	value = Global.master_volume

func _on_value_changed(v: float) -> void:
	AudioServer.set_bus_volume_db(0, v)
	Global.save_volume(v)
