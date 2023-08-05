extends CharacterBody2D

enum {
	MOVE,
	CLIMB,
	DASH,
}

@export var move_data: PlayerMovementData

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jumps = 0
var dash = 0
var dash_cooling = false
var state = MOVE

@onready var animated_sprite = $AnimatedSprite2D
@onready var spawn_position = position
@onready var ladder_check = $LadderCheck
@onready var dash_timer = $DashTimer
@onready var dash_cd_timer = $DashCooldownTimer
@onready var remote_transform_2d = $RemoteTransform2D


func _ready():
	add_to_group("Players")


func _physics_process(delta):
	var input = Vector2.ZERO
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input.x = Input.get_axis("left", "right")
	input.y = Input.get_axis("up", "down")
	
	match state:
		MOVE: 
			move_state(input.x, delta)	
			
		CLIMB: 
			climb_state(input)
			
		DASH:
			dash_state()


func move_state(direction: float, delta: float):
	if is_on_ladder() && \
	(Input.is_action_just_pressed("up") or \
	Input.is_action_just_pressed("down")):
		state = CLIMB
		return

	_walk(direction, delta)
	_fall(delta)
	_dash(direction)
	_jump(delta)

	var was_on_floor = is_on_floor()
	move_and_slide()
	
	_land(was_on_floor)


func climb_state(input: Vector2):
	if not is_on_ladder():
		state = MOVE
		return
		
	if input.length() != 0:
		animated_sprite.play("Run")
	else:
		animated_sprite.play("Idle")
	
	velocity = input * move_data.climb_speed
	move_and_slide()


func die():
	SoundPlayer.play_sound(SoundPlayer.HURT)
	Events.emit_signal("player_died")
	queue_free()


func connect_camera(camera: Camera2D):
	remote_transform_2d.remote_path = camera.get_path()


func dash_state():
	move_and_slide()


func is_on_ladder():
	if not ladder_check.is_colliding():
		return false
	else: 
		return true


func damage():
	die()


func _walk(direction: float, delta: float):
	if direction:
		var dynamicAcceleration = move_data.acceleration \
								  if direction * velocity.x >= 0 \
								  else move_data.friction
		
		velocity.x = move_toward(velocity.x, \
								 direction * move_data.speed, \
								 dynamicAcceleration * delta)
		
		animated_sprite.play("Run")
		animated_sprite.set_deferred("flip_h", direction > 0)
	else:
		velocity.x = move_toward(velocity.x, 0, move_data.friction * delta)
		animated_sprite.play("Idle")


func _fall(delta: float):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, 300)
		animated_sprite.play("Jumping")
	else:
		jumps = 0
		dash = 0


func _dash(direction: float):
	# Handle dash.
	if Input.is_action_just_pressed("dash") && direction &&\
	   dash < move_data.max_dash && not dash_cooling:
		dash += 1
		SoundPlayer.play_sound(SoundPlayer.DASH)
		dash_cooling = true
		dash_timer.wait_time = move_data.dash_length
		dash_timer.start()
		state = DASH
		velocity.x = direction * move_data.dash_velocity
		velocity.y = min(velocity.y, 0)


func _jump(delta: float):
	# Handle Jump.
	if jumps < move_data.max_jumps:		
		if Input.is_action_just_pressed("jump"):
			SoundPlayer.play_sound(SoundPlayer.JUMP)
			jumps += 1			
			velocity.y = move_data.jump_velocity
	else:
		if Input.is_action_just_released("jump") && \
		   velocity.y < move_data.min_jump_velocity:
			velocity.y = move_data.min_jump_velocity
		
		# When falling, apply an extra 50% gravity.
		if velocity.y > 0:
			velocity.y += gravity * delta * 0.5


func _land(was_on_floor: bool):
	if not was_on_floor and is_on_floor():
		animated_sprite.play("Run")
		animated_sprite.set_frame_and_progress(1, 0.0)


func _on_dash_timer_timeout():
	state = MOVE
	dash_cd_timer.wait_time = move_data.dash_cooldown
	dash_cd_timer.start()


func _on_dash_cooldown_timer_timeout():
	dash_cooling = false
