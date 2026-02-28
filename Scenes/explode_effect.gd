extends Node2D

func _ready() -> void:
	$explode.emitting = true
	await $explode.finished
	queue_free()
