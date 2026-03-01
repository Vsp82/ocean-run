extends Label

func _ready() -> void:
	text = _format(Global.run_time)
	Global.timer_running = true

func _process(delta: float) -> void:
	if Global.timer_running:
		Global.run_time += delta
		text = _format(Global.run_time)

func _format(t: float) -> String:
	var minutes := int(t) / 60
	var seconds := int(t) % 60
	var millis  := int(fmod(t, 1.0) * 1000)
	if minutes >= 60:
		var hours := minutes / 60
		minutes   = minutes % 60
		return "%d:%02d:%02d.%03d" % [hours, minutes, seconds, millis]
	return "%d:%02d.%03d" % [minutes, seconds, millis]
