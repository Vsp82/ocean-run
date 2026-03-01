extends CharacterBody2D


const  speed = 350
const ACCEL = 2000

@export var Health = 1
@export var player: Node2D
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
var moove := 5
var time := true
var vision := false
var immune = false

func _process(_delta: float) -> void:
	if Health <= 0:
		$".".hide()
		queue_free()

func _physics_process(_delta: float) -> void:
	var direction = to_local(nav_agent.get_next_path_position()).normalized()
	if vision and time:
		immune = true
		if direction.x < 0:
			$Sprite2D.flip_h = true
		elif direction.x > 0:
			$Sprite2D.flip_h = false
		velocity = direction * speed
		move_and_slide()
		moove -= 1
		if moove == 0:
			moove = 5
			time = false
			immune = false
			$Timer2.start()

func makepath() -> void:
	if Health > 0:
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



func _on_hitbox_body_entered(body) -> void:
	if body.is_in_group("Player"):
		Health -=1
		if Health <= 0:
			$".".hide()
			queue_free()
