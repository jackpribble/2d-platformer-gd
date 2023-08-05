extends Area2D

@onready var animated_sprite_2d = $AnimatedSprite2D

var active = true

func _on_body_entered(body):
	if not body.is_in_group("Players"):
		return

	if not active:
		return
		
	active = false
	animated_sprite_2d.play("Checked")
	Events.emit_signal("hit_checkpoint", position)
