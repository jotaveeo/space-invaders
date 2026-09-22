extends CharacterBody2D

@onready var animation_alien = $AnimationPlayer
@onready var audio_explosion = $AudioStreamPlayer

signal alien_eliminado

func explosion():
	animation_alien.play("destroy")
	audio_explosion.play()
	
func elimination():
	emit_signal("alien_eliminado", self)
	queue_free()
