extends CharacterBody2D

@export var Health := 4
@onready var CoyoteTime: Timer = $CoyoteTime
@onready var No_damage_time: Timer = $No_damage_time

@onready var explode_scene = preload(explode_scenes)
@onready var explode_up_scene = preload(explode_up_scenes)
@onready var text11 = preload(text1)
@onready var text22 = preload(text2)
@onready var cHealt = $"../CanvasLayer/Health"

var No_damage_time_active: bool = false
var Coyote_time_active: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity_modifier: float = 1
var water := true
var was_on_floor := false
var text := 0
var hit := true

const SPEED := 120.0
const ACCEL := 1500.0
const FRICTION := 1500.0
const JUMP_VELOCITY := -250.0
const WATER_JUMP_VELOCITY := -140.0
const WATER_SPEED := 70.0
const WATER_FRICTION := 400.0

const explode_scenes := "res://Scenes/explode_effect.tscn"
const explode_up_scenes := "res://Scenes/explode_up_effect.tscn"
const text1 := "res://Acets/image-removebg-preview.png"
const text2 := "res://Acets/WhatsApp_Image_2026-02-28_at_21.26.27-removebg-preview.png"

var airtime := 0.0

@onready var instakill := $"../Instakill"

# Tune these
const ZOOM_DEFAULT    := Vector2(6.0, 6.0)
const ZOOM_MAX_OUT    := Vector2(4.0, 4.0)   # how far it zooms out at full speed
const ZOOM_SPEED_REF  := 200.0               # speed at which max zoom is reached
const ZOOM_OUT_SPEED  := 6.0                 # how fast it zooms out
const ZOOM_IN_SPEED   := 2.0                 # how slowly it recovers (feels weightier)


func _process(_delta: float) -> void:
	cHealt.value = Health
	if text == 0:
		$GPUParticles2D.texture = text11
		text += 1
	else:
		$GPUParticles2D.texture = text22
		text -= 1
	if Input.is_action_just_pressed("Attack"):
		if hit:
			Attack()
			hit = false
			$Hit_Cooldown.start()

func _physics_process(delta: float) -> void:
	var current_speed    := WATER_SPEED    if water else SPEED
	var current_friction := WATER_FRICTION if water else FRICTION
	if velocity.y > 0:
		if water:
			gravity_modifier = 0.25   # slow the fall
		else:
			gravity_modifier = 1.0
	elif velocity.y < 0:
		if water:
			gravity_modifier = 0.45   # also resist rising
		else:
			gravity_modifier = 1.0
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
	# In _physics_process, replace the zoom block with this:
	var speed        := velocity.length()
	var speed_factor: float = clamp(speed / ZOOM_SPEED_REF, 0.0, 1.0)
	var target_zoom  := ZOOM_DEFAULT.lerp(ZOOM_MAX_OUT, speed_factor)

	# Asymmetric lerp: fast zoom-out, slow zoom-in
	var lerp_speed := ZOOM_OUT_SPEED if speed_factor > 0.01 else ZOOM_IN_SPEED
	$Camera2D.zoom = $Camera2D.zoom.lerp(target_zoom, lerp_speed * delta)
	if Input.is_action_just_pressed("Jump") and (!CoyoteTime.is_stopped() or is_on_floor()):
		velocity.y = WATER_JUMP_VELOCITY if water else JUMP_VELOCITY
		CoyoteTime.stop()
		Coyote_time_active = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	
	if direction < 0:
		$AnimatedSprite2D.flip_h = true
		$Attack.rotation_degrees = 180
		$Sprite2D2.position = Vector2(-11, 0)
	elif direction > 0:
		$AnimatedSprite2D.flip_h = false
		$Attack.rotation_degrees = 0
		$Sprite2D2.position = Vector2(11, 0)
	if direction:
		# moving
		velocity.x = move_toward(velocity.x, direction * current_speed, ACCEL * delta)
		$AnimatedSprite2D.play("Walk")
		$GPUParticles2D.emitting = true
	else:
		velocity.x = move_toward(velocity.x, 0, current_friction * delta)
		$AnimatedSprite2D.play("Idle")
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

func take_fall_damage() -> void:
	var explode = explode_up_scene.instantiate()
	explode.global_position = global_position
	get_parent().add_child(explode)
	var timer = $spawnreset
	timer.start()
	await timer.timeout
	Global.add_death()
	get_tree().call_deferred("reload_current_scene")

func take_damage() -> void:
	if No_damage_time_active:
		return
	if Global.rumble_enabled:
		Input.start_joy_vibration(0, 0.8, 0.3, 0.4)
	No_damage_time_active = true
	Health -= 1
	$AnimationPlayer.play("playeflash")
	No_damage_time.start()
	if Health <= 0: # dead
		Global.add_death()
		get_tree().call_deferred("reload_current_scene")

func _on_air_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		water = false

func _on_air_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		water = true

func _on_no_damage_time_timeout() -> void:
	No_damage_time_active = false
	$AnimationPlayer.stop()
	$AnimatedSprite2D.modulate.a = 1.0  # make sure player is fully visible again

func _ready() -> void:
	# default
	$AnimatedSprite2D.modulate.a = 1.0

func Attack():
	$Attack2.play("Attack")

func wait(seconds: float):
	await get_tree().create_timer(seconds).timeout


func _on_attack_body_entered(body) -> void:
	if body.is_in_group("Enemy"):
		body.Health -= 1

func _on_hit_cooldown_timeout() -> void:
	hit = true


func _on_instakill_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		take_fall_damage()
