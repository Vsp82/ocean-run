extends CharacterBody2D


const speed = 1000
const ACCEL = 2000

var v_u := false
var vision := false
@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D

func _physics_process(delta: float) -> void:
	if vision:
		var direction = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = direction * speed

		move_and_slide()
		velocity = direction * 0
		vision = false
		await wait(1)
		if v_u:
			vision = true

func makepath() -> void:
	nav_agent.target_position = player.global_position
	
func _on_timer_timeout() -> void:
	makepath()
	
func _on_vision_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		vision = true
		v_u = true
		
func _on_vision_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		vision = false
		v_u = false
		
func wait(seconds: float):
	await get_tree().create_timer(seconds).timeout
	
