extends CanvasLayer

signal transition_completed

@onready var animation_player = $AnimationPlayer

func play_exit_transition():
	animation_player.play("ExitLevel")


func play_enter_transition():
	animation_player.play("EnterLevel")


func _on_animation_player_animation_finished(anim_name):
	emit_signal("transition_completed")
