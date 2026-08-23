extends CharacterBody2D

@onready var time_movimento = $timerMovimento
@onready var animation_alien = $AnimationPlayer

var origin = 0
var distancia = 30
var passo = 7
var direction = 1

signal alien_eliminado

func _ready():
	time_movimento.start()
	origin = self.position.x

func _on_timer_movimento_timeout():
	self.position.x += direction * passo
	if self.position.x >= origin + distancia or self.position.x <= origin - distancia:
		direction *= -1
		
func explosion():
	animation_alien.play("destroy")
	
func elimination ():
	emit_signal("alien_eliminado", self)
	queue_free()
