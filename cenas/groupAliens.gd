extends Node

var Alien = preload("res://cenas/alien.tscn")
var Missel = preload("res://cenas/missel.tscn")
var Bonus = preload("res://cenas/bonus.tscn")
var Boss = preload("res://cenas/boss.tscn")

var lista_aliens = []
var formation_direction = 1
const FORMATION_SPEED = 12.0
const DESCENT_AMOUNT = 8.0
var move_timer = 0.0
const MOVE_INTERVAL = 1.0

@onready var wave_manager = get_node("/root/WaveManager")

var current_wave_composition = []
var formation_rows = 0
var formation_cols = 0
var alien_base_y = 40

func _ready():
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.boss_spawned.connect(_on_boss_spawned)
	wave_manager.wave_cleared.connect(_on_wave_cleared)
	
	$Timerbonus.wait_time = randf_range(3.0, 20.0)
	$Timerbonus.one_shot = false
	$Timerbonus.start()
	
	# Timer para aliens atirarem
	var timer_tiro = Timer.new()
	timer_tiro.wait_time = 2.0
	timer_tiro.one_shot = false
	timer_tiro.connect("timeout", Callable(self, "_on_timer_tiro_timeout"))
	add_child(timer_tiro)
	timer_tiro.start()

func _on_wave_started(wave_number):
	# Limpa formação anterior
	_clear_formation()
	lista_aliens.clear()
	
	# Reseta timer do bonus periódico
	$Timerbonus.wait_time = randf_range(15.0, 30.0)
	$Timerbonus.start()
	
	# Pega composição da onda
	current_wave_composition = wave_manager.get_wave_composition(wave_number)
	_spawn_formation_from_composition(wave_number)

func _spawn_formation_from_composition(_wave_number):
	formation_rows = 0
	var start_y = alien_base_y
	
	for entry in current_wave_composition:
		var rows = entry.rows
		var cols = entry.cols
		var enemy_type = entry.type
		
		for j in range(rows):
			lista_aliens.append([])
			for i in range(cols):
				var alien = Alien.instantiate()
				# Configura alien baseado no tipo
				_configure_alien(alien, enemy_type)
				alien.global_position = Vector2(30 + 22*i, start_y + 22*j)
				self.add_child(alien)
				lista_aliens[formation_rows].append(alien)
				alien.connect("alien_eliminado", Callable(self, "_on_alien_eliminated"))
				wave_manager.on_enemy_spawned()
			formation_rows += 1

func _configure_alien(alien, enemy_type):
	# Configura HP, cor, score baseado no tipo
	var type_data = wave_manager.enemy_types[enemy_type]
	if type_data:
		alien.hp = type_data.hp
		alien.max_hp = type_data.hp
		alien.enemy_type = enemy_type
		alien.score_value = type_data.score
		if alien.has_node("Sprite2D"):
			alien.get_node("Sprite2D").modulate = type_data.color

func _on_alien_eliminated(enemy_type, alien_node):
	# Remove da lista
	for fila in lista_aliens:
		if alien_node in fila:
			fila.erase(alien_node)
			break
	
	# Notifica wave manager
	wave_manager.on_enemy_killed(enemy_type, 0)
	
	# Notifica main para somar pontos
	get_parent().Somar_pontos_alien(enemy_type)

func _on_wave_cleared(_wave_number):
	# Spawna bonus de vitória (deferred para evitar erro de física)
	call_deferred("_spawn_victory_bonus")

func _spawn_victory_bonus():
	var bonus = Bonus.instantiate()
	bonus.global_position = Vector2(117, 20)
	bonus.direction = 1
	self.add_child(bonus)
	bonus.connect("bonus_eliminado", Callable(get_parent(), "somar_bonus"))

func _on_boss_spawned(_boss_node):
	# Spawna o boss
	var boss = Boss.instantiate()
	boss.global_position = Vector2(127, -50)
	self.add_child(boss)
	boss.connect("boss_killed", Callable(self, "_on_boss_killed"))
	boss.connect("shoot_pattern", Callable(self, "_on_boss_shoot_pattern"))

func _on_boss_killed():
	wave_manager.on_boss_killed()

func _on_boss_shoot_pattern(pattern_data):
	# Spawna projéteis do boss
	_spawn_boss_projectiles(pattern_data)

func _spawn_boss_projectiles(pattern_data):
	var position = pattern_data["position"]
	var shots = pattern_data["shots"]
	var spread = pattern_data["spread"]
	var homing = pattern_data["homing"]
	
	for i in range(shots):
		var angle = 0.0
		if shots > 1:
			angle = (i - (shots - 1) / 2.0) * spread * PI / 180.0
		else:
			angle = PI / 2.0  # Para baixo
		
		var missel = Missel.instantiate()
		missel.global_position = position
		if homing:
			# Tiro direcionado ao jogador
			var jogador = get_parent().get_node("jogador")
			if jogador.is_inside_tree():
				var dir = (jogador.global_position - position).normalized()
				angle = dir.angle()
		missel.rotation = angle
		get_parent().add_child(missel)

func _clear_formation():
	for fila in lista_aliens:
		for alien in fila:
			if alien and alien.is_inside_tree():
				alien.queue_free()
	lista_aliens.clear()

func _process(delta):
	move_timer += delta
	if move_timer >= MOVE_INTERVAL:
		move_timer = 0.0
		_move_formation()

func _move_formation():
	var borda_esquerda = 254
	var borda_direita = 0
	var tem_vivos = false
	
	# Encontra bordas da formação
	for fila in lista_aliens:
		for alien in fila:
			if alien and alien.is_inside_tree():
				tem_vivos = true
				if alien.global_position.x < borda_esquerda:
					borda_esquerda = alien.global_position.x
				if alien.global_position.x > borda_direita:
					borda_direita = alien.global_position.x
	
	if not tem_vivos:
		return
	
	# Verifica se bateu na borda
	var deve_descer = false
	if formation_direction > 0 and borda_direita >= 230:
		deve_descer = true
	elif formation_direction < 0 and borda_esquerda <= 24:
		deve_descer = true
	
	if deve_descer:
		formation_direction *= -1
		# Desce toda a formação
		for fila in lista_aliens:
			for alien in fila:
				if alien and alien.is_inside_tree():
					alien.global_position.y += DESCENT_AMOUNT
	else:
		# Move horizontalmente
		for fila in lista_aliens:
			for alien in fila:
				if alien and alien.is_inside_tree():
					alien.global_position.x += formation_direction * FORMATION_SPEED

func _on_timer_tiro_timeout():
	# Escolhe um alien vivo aleatório para atirar
	var aliens_vivos = []
	for fila in lista_aliens:
		for alien in fila:
			if alien and alien.is_inside_tree():
				aliens_vivos.append(alien)
			elif not alien:
				# Remove referências nulas
				fila.erase(alien)
				
	if aliens_vivos.size() > 0:
		var atirador = aliens_vivos.pick_random()
		var missel = Missel.instantiate()
		missel.global_position = atirador.global_position
		get_parent().add_child(missel)

func _on_timerbonus_timeout():
	var bonus = Bonus.instantiate()
	# Spawna sempre do lado esquerdo
	bonus.global_position = Vector2(-20, 20)
	bonus.direction = 1
	self.add_child(bonus)
	bonus.connect("bonus_eliminado", Callable(get_parent(), "somar_bonus"))
