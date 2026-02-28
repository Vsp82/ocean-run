extends CharacterBody2D

@export var Health := 4
@onready var CoyoteTime: Timer = $CoyoteTime
@onready var No_damage_time: Timer = $No_damage_time
@export var explode_scene : PackedScene

var No_damage_time_active: bool = false
var Coyote_time_active: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity_modifier: float = 1
var water := true
var was_on_floor := false

const SPEED := 120.0
const ACCEL := 1500.0
const FRICTION := 1500.0
const JUMP_VELOCITY := -250.0
var airtime := 0.0


const DEFZOOM := [6.0, 6.0]

func _process(_delta: float) -> void:
	$"../CanvasLayer/Health".value = Health

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
		
		# cam zoom on velocity
		airtime += delta
		
		if !Coyote_time_active:
			CoyoteTime.start()
			Coyote_time_active = true
	else:
		airtime = 0
		if Coyote_time_active:
			Coyote_time_active = false
			CoyoteTime.stop()
	var speed_factor = clamp(airtime / 0.75, 0.0, 0.5)  # 1.5 = seconds to reach max zoom out
	var target_zoom = Vector2(6.0, 6.0) - Vector2(2.0, 2.0) * speed_factor
	# $Camera2D.zoom = $Camera2D.zoom.lerp(target_zoom, 5.0 * delta)
	if Input.is_action_just_pressed("Jump") and (!CoyoteTime.is_stopped() or is_on_floor() ):
		velocity.y = JUMP_VELOCITY
		CoyoteTime.stop()
		Coyote_time_active = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	
	if direction < 0:
		$Sprite2D.flip_h = true
	elif direction > 0:
		$Sprite2D.flip_h = false
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
	if Global.rumble_enabled:
		var impact = clamp(airtime / 1.5, 0.1, 1.0)
		Input.start_joy_vibration(0, impact, impact, 0.1)	
	var explosion = explode_scene.instantiate()
	explosion.global_position = global_position
	get_parent().add_child(explosion)

func take_damage() -> void:
	if No_damage_time_active:
		return
	if Global.rumble_enabled:
		Input.start_joy_vibration(0, 0.8, 0.3, 0.4)
	No_damage_time_active = true
	Health -= 1
	$AnimationPlayer.play("playeflash")
	No_damage_time.start()
	print(Health)
	if Health <= 0: # dead
		Global.add_death()
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
