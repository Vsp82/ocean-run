extends Node2D
func _ready() -> void:
	print("spawned explode")
	$explode.one_shot = true
	$explode.emitting = true
	await $explode.finished
	queue_free()
