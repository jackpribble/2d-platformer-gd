extends Area2D

@export_file("*.tscn") var target_level_path: String

var _player: CharacterBody2D = null


func go_to_next_room():
	Transitions.play_exit_transition()		
	get_tree().paused = true	
	
	await Transitions.transition_completed	
	
	Transitions.play_enter_transition()	
	get_tree().paused = false	
	
	get_tree().change_scene_to_file(target_level_path)


func _process(_delta):
	if not _player or not _player.is_on_floor(): 
		return
	
	if Input.is_action_just_pressed("up"):
		if target_level_path.is_empty():
			return
			
		go_to_next_room()


func _on_body_entered(body):
	if not body.is_in_group("Players"):
		return
		
	_player = body


func _on_body_exited(body):
	if not body.is_in_group("Players"):
		return
		
	_player = null
