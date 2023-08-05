extends Node2D

enum {
	RISE,
	FALL,
	HOVER,
	LAND,
}

@export var falling_velocity = 80.0
@export var rising_velocity = 40.0
@export var pause_time = 1.0

var state = HOVER

@onready var start_position = global_position
@onready var ray_cast_2d = $RayCast2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var timer = $Timer
@onready var gpu_particles_2d = $GPUParticles2D

func _ready():
	add_to_group("Enemies")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	match state:
		HOVER: hover()
		RISE: rise(delta)
		FALL: fall(delta)
		LAND: land()


func hover():
	state = FALL
	
	
func rise(delta: float):
	animated_sprite_2d.play("Rising")
	position.y = move_toward(position.y, start_position.y, rising_velocity * delta)
	
	if position.y == start_position.y:
		state = HOVER
	
	
func fall(delta: float):
	animated_sprite_2d.play("Falling")
	position.y += falling_velocity * delta
	
	if ray_cast_2d.is_colliding():
		var collision_point = ray_cast_2d.get_collision_point()
		position.y = collision_point.y
		_to_land()

	
func land(): 
	if timer.time_left == 0:
		state = RISE


func _to_land():
	timer.start(pause_time)
	gpu_particles_2d.emitting = true
	state = LAND
