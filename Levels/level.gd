extends Node2D

const player_scene_pck = preload("res://Player/player.tscn")

@onready var camera_2d = $Camera2D
@onready var player = $Player

var player_spawn_location = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color.LIGHT_BLUE)
	player.connect_camera(camera_2d)
	Events.player_died.connect(_on_player_died)
	player_spawn_location = player.global_position
	Events.hit_checkpoint.connect(_on_hit_checkpoint)
	
func _on_player_died():
	var player_i = player_scene_pck.instantiate()
	player_i.add_to_group("Players")
	player_i.set_deferred("global_position", player_spawn_location)
	call_deferred("add_child", player_i)
	player_i.call_deferred("connect_camera", camera_2d)


func _on_hit_checkpoint(checkpoint_pos: Vector2):
	player_spawn_location = checkpoint_pos
