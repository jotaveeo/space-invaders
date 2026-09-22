extends CharacterBody2D

signal bonus_eliminado
var velocidade = 50

func _process(delta):
	position.x -= velocidade * delta

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "destruido":
		emit_signal("bonus_eliminado")

func explodir():
	$AnimationPlayer.play("destruido")
