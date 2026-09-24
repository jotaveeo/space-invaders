extends Node

signal wave_started(wave_number: int)
signal wave_cleared(wave_number: int)
signal boss_spawned(boss_node)
signal game_over_timeout

# Configuração de ondas
const BASE_WAVE_TIME = 60.0
const TIME_PER_WAVE = -2.0  # Cada onda tem menos tempo
const MIN_WAVE_TIME = 30.0
const EXTRA_LIFE_SCORE_THRESHOLD = 5000
const BOSS_EVERY_N_WAVES = 3

var current_wave = 0
var wave_timer = 0.0
var wave_active = false
var enemies_spawned = 0
var enemies_killed = 0
var score_at_last_extra_life = 0
var boss_active = false

# Definição de tipos de inimigo por onda
var enemy_types = {
	"virus": {"hp": 1, "color": Color(0, 1, 0.3), "size": Vector2(16, 16), "speed_mult": 1.0, "score": 100},
	"malware": {"hp": 2, "color": Color(1, 0, 1), "size": Vector2(20, 20), "speed_mult": 0.9, "score": 200},
	"ransomware": {"hp": 3, "color": Color(1, 0.2, 0.2), "size": Vector2(24, 24), "speed_mult": 0.8, "score": 300, "special": "lock_shot"},
	"botnet": {"hp": 1, "color": Color(1, 1, 0), "size": Vector2(12, 12), "speed_mult": 1.5, "score": 150},
}

func _ready():
	pass

func start_game():
	current_wave = 0
	score_at_last_extra_life = 0
	start_next_wave()

func start_next_wave():
	current_wave += 1
	wave_active = true
	enemies_spawned = 0
	enemies_killed = 0
	boss_active = false
	
	# Calcula tempo da onda
	var wave_time = max(BASE_WAVE_TIME + (current_wave - 1) * TIME_PER_WAVE, MIN_WAVE_TIME)
	wave_timer = wave_time
	
	emit_signal("wave_started", current_wave)
	
	# Verifica se é onda de boss
	if current_wave % BOSS_EVERY_N_WAVES == 0:
		boss_active = true
		emit_signal("boss_spawned", null)  # null porque o boss será criado pelo groupAliens

func get_wave_composition(wave_num):
	var comp = []
	
	# Linha 0-1: sempre vírus
	comp.append({"type": "virus", "rows": 2, "cols": 8})
	
	if wave_num >= 2:
		# Linha 2: malware
		comp.append({"type": "malware", "rows": 1, "cols": 8})
	
	if wave_num >= 3:
		# Linha 3: ransomware
		comp.append({"type": "ransomware", "rows": 1, "cols": 6})
	
	if wave_num >= 4:
		# Adiciona botnet na linha extra
		comp.append({"type": "botnet", "rows": 1, "cols": 10})
	
	if wave_num >= 5:
		# Mais ransomware
		comp.append({"type": "ransomware", "rows": 1, "cols": 8})
	
	return comp

func _spawn_boss_deferred():
	# Será chamado pelo groupAliens quando formação estiver pronta
	boss_active = true

func on_enemy_spawned():
	enemies_spawned += 1

func on_enemy_killed(_enemy_type, _score_gained):
	enemies_killed += 1
	_check_extra_life(_score_gained)
	
	if enemies_killed >= enemies_spawned and not boss_active:
		_wave_cleared()

func _check_extra_life(_score_gained):
	# Verifica se passou do threshold para vida extra
	# O main vai manter o score total, aqui só avisamos
	# Implementação real: main conecta sinal e verifica
	pass

func _wave_cleared():
	wave_active = false
	emit_signal("wave_cleared", current_wave)
	
	# Pequeno delay antes da próxima onda
	get_tree().create_timer(2.0).timeout.connect(start_next_wave.bind())

func on_boss_killed():
	boss_active = false
	emit_signal("wave_cleared", current_wave)
	get_tree().create_timer(3.0).timeout.connect(start_next_wave.bind())

func get_wave_timer():
	return wave_timer

func get_current_wave():
	return current_wave

func is_wave_active():
	return wave_active

func is_boss_active():
	return boss_active

func _process(_delta):
	if wave_active and not boss_active:
		wave_timer -= _delta
		if wave_timer <= 0:
			wave_timer = 0
			emit_signal("game_over_timeout")
