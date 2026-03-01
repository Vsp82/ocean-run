extends CharacterBody2D
const ACCEL = 2000
@export var Health = 1
@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
var moove := 5
var time := true
var vision := false
var immune = false
var speed = 750
var target_velocity := Vector2.ZERO
var swim_time := 0.0

func _process(delta: float) -> void:
	if Health <= 0:
		$".".hide()
		queue_free()
	swim_time += delta

func _physics_process(delta: float) -> void:
	var direction = to_local(nav_agent.get_next_path_position()).normalized()
	if vision and time:
		$AnimatedSprite2D.play("base")
		immune = true
		if direction.x < 0:
			$AnimatedSprite2D.flip_h = true
		elif direction.x > 0:
			$AnimatedSprite2D.flip_h = false
		
		var pulse = pow(abs(sin(swim_time * 3.0)), 0.2)
		target_velocity = direction * speed * pulse
		moove -= 1
		if moove == 0:
			moove = 5
			time = false
			immune = false
			$Timer2.start()
	else:
		# Drift to a stop smoothly
		target_velocity = Vector2.ZERO

	velocity = velocity.lerp(target_velocity, 0.2)
	move_and_slide()

func makepath() -> void:
	if Health > 0:
		nav_agent.target_position = player.global_position

func _on_timer_timeout() -> void:
	makepath()

func _on_vision_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		vision = true
		speed = 350

func wait(seconds: float):
	await get_tree().create_timer(seconds).timeout

func _on_timer_2_timeout() -> void:
	time = true

func _on_hitbox_body_entered(body) -> void:
	if body.is_in_group("Player"):
		Health -= 1
		if Health <= 0:
			$".".hide()
			queue_free()

func _on_vision_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		speed = 900
