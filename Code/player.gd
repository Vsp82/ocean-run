extends CharacterBody2D

@export var Health = 0
@onready var CoyoteTime: Timer = $CoyoteTime
@onready var No_damage_time: Timer = $No_damage_time
var No_damage_time_active: bool = false
var Coyote_time_active: bool = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity_modifier: float = 1
var water := true



const SPEED := 200.0
const JUMP_VELOCITY := -300.0


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
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()





func _on_air_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		water = false

func _on_air_body_exited(body: CharacterBody2D) -> void:
	
	if body.is_in_group("Player"):
		water = true


func _on_damage_damage() -> void:
	print("damage yes")
	if No_damage_time_active == false:
		Health -= 1
		print(Health)
		No_damage_time.start()


func _on_no_damage_time_timeout() -> void:
	No_damage_time_active = false
