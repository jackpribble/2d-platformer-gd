extends Node

const HURT = preload("res://Sounds/hurt.wav")
const JUMP = preload("res://Sounds/jump.wav")
const DASH = preload("res://Sounds/dash.wav")

@onready var audio_players = $AudioPlayers

func play_sound(sound):
	for player in audio_players.get_children() as Array[AudioStreamPlayer]:
		if not player.playing:
			player.stream = sound
			player.play()
			break
