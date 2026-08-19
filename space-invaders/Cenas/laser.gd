extends Area2D

var velocity = 200

func _process(delta):
	position.y -= velocity * delta
