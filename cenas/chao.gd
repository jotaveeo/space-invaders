extends Node

signal chao_destroyed

var Bloco = preload("res://cenas/bloco.tscn")
var blocos_chao = []

func _ready():
	var bloco = Bloco.instantiate()
	var largura_da_tela = 224
	var altura_da_tela = 256
	var n_blocos = int(largura_da_tela / 3)
	
	for i in range(n_blocos):
		bloco = Bloco.instantiate()
		bloco.global_position = Vector2(2 + i * 4, altura_da_tela + 1)
		add_child(bloco)
		blocos_chao.append(bloco)
		bloco.connect("tree_exited", Callable(self, "_on_bloco_destroyed").bind(bloco))

func _on_bloco_destroyed(bloco):
	blocos_chao.erase(bloco)
	if blocos_chao.is_empty():
		emit_signal("chao_destroyed")
