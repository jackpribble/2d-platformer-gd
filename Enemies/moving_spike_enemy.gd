@tool
extends Path2D

enum AnimationType {
	LOOP,
	BOUNCE,
}

@export var animation_type: AnimationType : set = set_animation_type
@export var animation_speed: float = 1 : set = set_animation_speed

@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Enemies")
	play_animation(animation_player)
			
			
func play_animation(player):
	match animation_type:
		AnimationType.LOOP:
			player.play("move_along_path")
			
		AnimationType.BOUNCE:
			player.play("move_along_path_return")
			

func set_animation_speed(value):
	animation_speed = value
	var player = find_child("AnimationPlayer") as AnimationPlayer
	if player:
		player.speed_scale = value


func set_animation_type(value):
	animation_type = value
	var player = find_child("AnimationPlayer")
	if player: play_animation(player)
