extends CharacterBody2D

@export var Health := 4
@onready var CoyoteTime: Timer = $CoyoteTime
@onready var No_damage_time: Timer = $No_damage_time
@onready var explode_scene = preload(explode_scenes)
@onready var text11 = preload(text1)
@onready var text22 = preload(text2)
@onready var cHealt = $"../CanvasLayer/Health"

var No_damage_time_active: bool = false
var Coyote_time_active: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity_modifier: float = 1
var water := true
var was_on_floor := false
var text = 0

const SPEED := 120.0
const ACCEL := 1500.0
const FRICTION := 1500.0
const JUMP_VELOCITY := -250.0
const explode_scenes := "res://Scenes/explode_effect.tscn"
const text1 := "res://Acets/image-removebg-preview.png"
const text2 := "res://Acets/WhatsApp_Image_2026-02-28_at_21.26.27-removebg-preview.png"

func _process(_delta: float) -> void:
	cHealt.value = Health
	if text == 0:
		$GPUParticles2D.texture = text11
		text += 1
	else:
		$GPUParticles2D.texture = text22
		text -= 1
	if Input.is_action_just_pressed("Attack"):
		Attack()


func _physics_process(delta: float) -> void:
	
	if velocity.y > 0:
		if water:
			gravity_modifier = 0.5
		else:
			gravity_modifier = 1
	elif velocity.y < 0:
		gravity_modifier = 1
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * gravity_modifier * delta
		if !Coyote_time_active:
			CoyoteTime.start()
			Coyote_time_active = true
	else:
		if Coyote_time_active:
			Coyote_time_active = false
			CoyoteTime.stop()
	if Input.is_action_just_pressed("Jump") and (!CoyoteTime.is_stopped() or is_on_floor() ):
		velocity.y = JUMP_VELOCITY
		CoyoteTime.stop()
		Coyote_time_active = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	
	if direction < 0:
		$Sprite2D.flip_h = true
		$Attack.rotation_degrees = 180
		$Sprite2D2.position = Vector2(-11, 0)
	elif direction > 0:
		$Sprite2D.flip_h = false
		$Attack.rotation_degrees = 0
		$Sprite2D2.position = Vector2(11, 0)
	if direction:
		# moving
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCEL * delta)
		$GPUParticles2D.emitting = true
	else:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		$GPUParticles2D.emitting = false
		

	move_and_slide()
	
	if is_on_floor() and !was_on_floor:
		_on_landed()
	
	was_on_floor = is_on_floor()

func _on_landed() -> void:
	var explosion = explode_scene.instantiate()
	explosion.global_position = global_position
	get_parent().add_child(explosion)

func take_damage() -> void:
	if No_damage_time_active:
		return
	No_damage_time_active = true
	Health -= 1
	$AnimationPlayer.play("playeflash")
	No_damage_time.start()
	print(Health)
	if Health <= 0:
		get_tree().reload_current_scene()

func _on_air_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		water = false

func _on_air_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		water = true

func _on_no_damage_time_timeout() -> void:
	No_damage_time_active = false
	$AnimationPlayer.stop()
	$Sprite2D.modulate.a = 1.0  # make sure player is fully visible again

func _ready() -> void:
	# default
	$Sprite2D.modulate.a = 1.0

func Attack():
	print("attack")
	$Attack2.play("Attack")

func wait(seconds: float):
	await get_tree().create_timer(seconds).timeout


func _on_attack_body_entered(body) -> void:
	if body.is_in_group("Enemy"):
		print("Enemy hit")
		body.Health -= 1
