extends Node

var pontos = 0
var vidas = 3
@onready var label_pontos = $VBoxContainer/LabelPontos
@onready var label_vidas = $HBoxContainer/LabelVidas  
@onready var jogador = $jogador

func _ready():
	jogador.vida_perdida.connect(_on_jogador_vida_perdida)
	jogador.game_over.connect(_on_jogador_game_over)

func Somar_pontos_alien(_a):
	pontos += 100
	label_pontos.text = str(pontos)

func somar_bonus(_bonus):
	pontos += 500
	label_pontos.text = str(pontos)

func _on_jogador_vida_perdida(vidas_restantes):
	vidas = vidas_restantes
	label_vidas.text = "Vidas: " + str(vidas)

func _on_jogador_game_over():
	get_tree().change_scene_to_file("res://cenas/gameover.tscn")
