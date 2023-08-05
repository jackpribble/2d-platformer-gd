extends CharacterBody2D


const SPEED = 25.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction = Vector2.RIGHT

@onready var ledge_check = $LedgeCheck
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	add_to_group("Enemies")


func _physics_process(delta):
	var found_wall = is_on_wall()
	var found_ledge = not ledge_check.is_colliding()
	
	if found_wall or found_ledge:
		direction *= -1
		ledge_check.position.x *= -1
		animated_sprite.set_deferred("flip_h", not animated_sprite.flip_h)
		
	
	velocity = direction * SPEED
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()
