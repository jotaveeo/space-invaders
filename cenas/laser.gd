extends Area2D

var velocity = 200

func _process(delta):
	position.y -= velocity * delta

func _on_body_entered(body):
	if body.is_in_group("aliens"):
		if body.has_method("take_damage"):
			body.take_damage(1)
		else:
			body.explosion()
		call_deferred("queue_free")
	elif body.is_in_group("blocos"):
		body.destruir()
		call_deferred("queue_free")
