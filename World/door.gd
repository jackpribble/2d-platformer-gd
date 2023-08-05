extends Area2D

@export_file("*.tscn") var target_level_path: String


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _on_body_entered(body):
	if not body.is_in_group("Players"):
		return
		
	if target_level_path.is_empty():
		return
	
	get_tree().change_scene_to_file(target_level_path)
