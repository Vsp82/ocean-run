extends Label

func _ready() -> void:
	text = str(int(Global.score)).lpad(9, "0")

func _process(delta: float) -> void:
	if Global.score != Global.realscore:
		var diff = Global.realscore - Global.score
		var step = ceil(abs(diff) * 10 * delta)
		Global.score += step if diff > 0 else -step
		Global.score = int(clamp(Global.score, min(Global.score, Global.realscore), max(Global.score, Global.realscore)))
		text = str(int(Global.score)).lpad(9, "0")
