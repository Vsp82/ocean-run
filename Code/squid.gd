extends CharacterBody2D


const  speed = 350
const ACCEL = 2000

var vision := false
@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
var moove := 5
var time := true


func _physics_process(delta: float) -> void:
	var direction = to_local(nav_agent.get_next_path_position()).normalized()
	if vision and time:
		if direction.x < 0:
			$Sprite2D.flip_h = true
		elif direction.x > 0:
			$Sprite2D.flip_h = false
		velocity = direction * speed
		#velocity.x = move_toward(velocity.x, direction.x * speed, ACCEL * delta)
		#velocity.y = move_toward(velocity.y, direction.y * speed, ACCEL * delta)
		move_and_slide()
		moove -= 1
		if moove == 0:
			moove = 5
			time = false
			$Timer2.start()

func makepath() -> void:
	nav_agent.target_position = player.global_position
	
func _on_timer_timeout() -> void:
	makepath()
	
func _on_vision_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		vision = true

func wait(seconds: float):
	await get_tree().create_timer(seconds).timeout


func _on_timer_2_timeout() -> void:
	time = true
