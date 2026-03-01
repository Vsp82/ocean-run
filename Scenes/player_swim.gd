extends CharacterBody2D

@export var Health := 8
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
var dir_r 

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
	var speed        := velocity.length()
	# Get direction to mouse
	var direction := get_global_mouse_position() - global_position
	# Move only if mouse is far enough away to prevent shaking
	if direction.length() > 5:
		velocity = direction.normalized() * speed
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()
		

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
	Health -= 2
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
