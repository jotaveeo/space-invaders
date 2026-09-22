extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var audio_explosion = $AudioStreamPlayer

const SPEED = 80.0
var direction = 1

signal bonus_eliminado

func _physics_process(_delta):
	velocity.x = direction * SPEED
	move_and_slide()
	
	# Sai da tela → remove
	if (direction > 0 and global_position.x > 260) or (direction < 0 and global_position.x < -20):
		queue_free()

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "destruido":
		emit_signal("bonus_eliminado", self)
		queue_free()

func destruir():
	animation_player.play("destruido")
	audio_explosion.play()

func explosion():
	destruir()
