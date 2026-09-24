extends Node

var pontos = 0
var vidas = 3
var wave_timer = 0.0
var current_wave = 1
var score_at_last_extra_life = 0

@onready var label_pontos = $VBoxContainer/LabelPontos
@onready var label_vidas = $HBoxContainer/LabelVidas
@onready var label_wave = $HBoxContainer/LabelWave
@onready var label_timer = $HBoxContainer/LabelTimer
@onready var jogador = $jogador

func _ready():
	jogador.vida_perdida.connect(_on_jogador_vida_perdida)
	jogador.game_over.connect(_on_jogador_game_over)
	
	# Conecta sinais do WaveManager
	WaveManager.wave_started.connect(_on_wave_started)
	WaveManager.wave_cleared.connect(_on_wave_cleared)
	WaveManager.game_over_timeout.connect(_on_game_over_timeout)
	WaveManager.boss_spawned.connect(_on_boss_spawned)
	
	# Conecta sinal do chao (linha de fundo)
	$chao.chao_destroyed.connect(_on_chao_destroyed)
	
	# Inicia o jogo
	WaveManager.start_game()

func _process(delta):
	# Atualiza timer da onda
	if WaveManager.is_wave_active():
		wave_timer = WaveManager.get_wave_timer()
		var minutes = int(wave_timer) / 60
		var seconds = int(wave_timer) % 60
		label_timer.text = "TIME: %02d:%02d" % [minutes, seconds]

func Somar_pontos_alien(enemy_type):
	# Score baseado no tipo de inimigo
	var scores = {"virus": 100, "malware": 200, "ransomware": 300, "botnet": 150}
	pontos += scores.get(enemy_type, 100)
	label_pontos.text = str(pontos)
	_check_extra_life()

func somar_bonus(_bonus):
	pontos += 500
	label_pontos.text = str(pontos)
	_check_extra_life()

func _check_extra_life():
	# Vida extra a cada 5000 pontos
	if pontos >= score_at_last_extra_life + 5000:
		score_at_last_extra_life += 5000
		if vidas < 5:
			vidas += 1
			jogador.vidas = vidas
			jogador.emit_signal("vida_perdida", vidas)

func _on_jogador_vida_perdida(vidas_restantes):
	vidas = vidas_restantes
	label_vidas.text = "LIVES: %d" % vidas

func _on_wave_started(wave_number):
	current_wave = wave_number
	label_wave.text = "WAVE: %02d" % wave_number
	wave_timer = WaveManager.get_wave_timer()

func _on_wave_cleared(wave_number):
	# Pequena pausa, próxima onda inicia automaticamente via WaveManager
	pass

func _on_game_over_timeout():
	# Tempo acabou - Game Over (ignora se GOD_MODE)
	if jogador.GOD_MODE:
		return
	call_deferred("_do_game_over_timeout")

func _do_game_over_timeout():
	if get_tree():
		get_tree().change_scene_to_file("res://cenas/gameover.tscn")

func _on_boss_spawned(boss_node):
	# Boss ativo - pode adicionar UI especial
	pass

func _on_chao_destroyed():
	# Linha de fundo destruída - Game Over (ignora se GOD_MODE)
	if jogador.GOD_MODE:
		return
	call_deferred("_do_chao_game_over")

func _do_chao_game_over():
	if get_tree() and get_tree().current_scene == self:
		get_tree().change_scene_to_file("res://cenas/gameover.tscn")

func _on_jogador_game_over():
	# Evita múltiplas chamadas
	if get_tree() and get_tree().current_scene == self:
		call_deferred("_do_jogador_game_over")

func _do_jogador_game_over():
	if get_tree() and get_tree().current_scene == self:
		get_tree().change_scene_to_file("res://cenas/gameover.tscn")
