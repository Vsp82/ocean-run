extends Label

func _ready() -> void:
	text = "Score: " + str(int(Global.score)).lpad(9, "0")
