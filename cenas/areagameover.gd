extends Area2D

@onready var jogador = get_parent().get_node("jogador")

func _on_area_entered(area):
	if area.is_in_group("misseis"):
		if jogador.GOD_MODE:
			return
		call_deferred("_do_gameover")
		
func _do_gameover():
	if get_tree():
		get_tree().change_scene_to_file("res://cenas/gameover.tscn")
		
