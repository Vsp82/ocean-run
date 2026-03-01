extends Label

func _format(t: float) -> String:
	var minutes := int(t) / 60
	var seconds := int(t) % 60
	var millis  := int(fmod(t, 1.0) * 1000)
	if minutes >= 60:
		var hours := minutes / 60
		minutes   = minutes % 60
		return "%d:%02d:%02d.%03d" % [hours, minutes, seconds, millis]
	return "%d:%02d.%03d" % [minutes, seconds, millis]
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.timer_running = false
	text = _format(Global.run_time)
