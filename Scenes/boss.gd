extends CharacterBody2D

@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
var target_velocity := Vector2.ZERO
var Health = 5
var speed = 120
const ACCEL = 2000

func _physics_process(_delta: float) -> void:
	var direction = to_local(nav_agent.get_next_path_position()).normalized()
	if direction.x < 0:
		$Sprite2D.flip_h = true
	elif direction.x > 0:
		$Sprite2D.flip_h = false
	target_velocity = direction * speed 

	velocity = velocity.lerp(target_velocity, 0.2)
	move_and_slide()

func makepath() -> void:
	if Health > 0:
		nav_agent.target_position = player.global_position

func _on_timer_timeout() -> void:
	makepath()
