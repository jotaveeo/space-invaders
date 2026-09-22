extends Area2D


func _on_area_entered(area):
	if area.is_in_group("misseis"):
		call_deferred("_do_gameover")
		
func _do_gameover():
	get_tree().change_scene_to_file("res://cenas/gameover.tscn")
		
