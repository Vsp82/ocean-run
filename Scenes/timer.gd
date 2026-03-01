extends Label

var time: float = 0.0
var running: bool = false

func _ready() -> void:
	text = "0:00.000"
	running = true

func _process(delta: float) -> void:
	if running:
		time += delta
		_update_display()

func _update_display() -> void:
	text = _format(time)

func _format(t: float) -> String:
	var minutes := int(t) / 60
	var seconds := int(t) % 60
	var millis  := int(fmod(t, 1.0) * 1000)

	if minutes >= 60:
		var hours := minutes / 60
		minutes   = minutes % 60
		return "%d:%02d:%02d.%03d" % [hours, minutes, seconds, millis]

	return "%d:%02d.%03d" % [minutes, seconds, millis]
