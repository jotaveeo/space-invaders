extends CharacterBody2D

@onready var animation_alien = $AnimationPlayer
@onready var audio_explosion = $AudioStreamPlayer
@onready var sprite = $Sprite2D

signal alien_eliminado

var hp = 1
var max_hp = 1
var enemy_type = "virus"
var score_value = 100
var use_placeholder = false  # Se true, usa _draw() colorido; se false, usa sprite com modulate

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		# Toca animação de destruição antes de remover
		animation_alien.play("destroy")
		audio_explosion.play()

func explosion():
	animation_alien.play("destroy")
	audio_explosion.play()
	
func elimination():
	emit_signal("alien_eliminado", enemy_type, self)
	queue_free()

func _draw():
	if use_placeholder and not sprite.texture:
		# Placeholder visual baseado no tipo
		var colors = {
			"virus": Color(0, 1, 0.3),
			"malware": Color(1, 0, 1),
			"ransomware": Color(1, 0.2, 0.2),
			"botnet": Color(1, 1, 0),
		}
		var c = colors.get(enemy_type, Color(1, 1, 1))
		var w = 16
		var h = 16
		draw_rect(Rect2(-w/2, -h/2, w, h), c)
		# Barra de vida
		if max_hp > 1:
			var bar_w = 14
			draw_rect(Rect2(-bar_w/2, h/2 + 2, bar_w, 3), Color(0.3, 0, 0))
			draw_rect(Rect2(-bar_w/2, h/2 + 2, bar_w * (hp / max_hp), 3), Color(1, 0.2, 0.2))
