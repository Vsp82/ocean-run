extends Node2D

@onready var scorelabel: Label = $CanvasLayer/score

var score = 0
var realscore = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer.show()

func _process(delta: float) -> void:
	if score != realscore:
		var diff = realscore - score
		var step = ceil(abs(diff) * 10 * delta)
		score += step if diff > 0 else -step
		score = int(clamp(score, min(score, realscore), max(score, realscore)))
		scorelabel.text = str(int(score)).lpad(9, "0")

# -1 for negative pnts
func add_score(pnts: int) -> void:
	realscore += pnts

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://Scenes/area_2.tscn")


func _on_health_value_changed(value: float) -> void:
	pass # Replace with function body.
