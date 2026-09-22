extends Node

var Alien = preload("res://cenas/alien.tscn")
var Missel = preload("res://cenas/missel.tscn")
var Bonus = preload("res://cenas/bonus.tscn")

var lista_aliens = []
var formation_direction = 1
const FORMATION_SPEED = 12.0
const DESCENT_AMOUNT = 8.0
var move_timer = 0.0
const MOVE_INTERVAL = 1.0

func _ready():
	$Timerbonus.wait_time = randf_range(3.0, 20.0)
	$Timerbonus.one_shot = false
	$Timerbonus.start()
	for j in range(4):
		lista_aliens.append([])
		for i in range(8):
			var alien = Alien.instantiate()
			alien.global_position = Vector2(50+20*i, 40+20*j)
			self.add_child(alien)
			lista_aliens[j].append(alien)
			alien.connect("alien_eliminado", Callable(self, "eliminar_alien"))
			alien.connect("alien_eliminado", Callable(get_parent(), "Somar_pontos_alien"))
			
	# Timer para aliens atirarem
	var timer_tiro = Timer.new()
	timer_tiro.wait_time = 2.0
	timer_tiro.one_shot = false
	timer_tiro.connect("timeout", Callable(self, "_on_timer_tiro_timeout"))
	add_child(timer_tiro)
	timer_tiro.start()

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
			if alien.is_inside_tree():
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
				if alien.is_inside_tree():
					alien.global_position.y += DESCENT_AMOUNT
	else:
		# Move horizontalmente
		for fila in lista_aliens:
			for alien in fila:
				if alien.is_inside_tree():
					alien.global_position.x += formation_direction * FORMATION_SPEED

func eliminar_alien(a):
	for fila in lista_aliens:  
		if a in fila:
			fila.erase(a)
	
	# Verifica se todos os aliens foram eliminados
	var total_vivos = 0
	for fila in lista_aliens:
		total_vivos += fila.size()
	if total_vivos == 0:
		# Spawna bonus de vitória
		var bonus = Bonus.instantiate()
		bonus.global_position = Vector2(117, 20)
		bonus.direction = 1
		self.add_child(bonus)
		bonus.connect("bonus_eliminado", Callable(get_parent(), "somar_bonus"))

func _on_timer_tiro_timeout():
	# Escolhe um alien vivo aleatório para atirar
	var aliens_vivos = []
	for fila in lista_aliens:
		for alien in fila:
			if alien.is_inside_tree():
				aliens_vivos.append(alien)
				
	if aliens_vivos.size() > 0:
		var atirador = aliens_vivos.pick_random()
		var missel = Missel.instantiate()
		missel.global_position = atirador.global_position
		get_parent().add_child(missel)


func _on_timerbonus_timeout():
	var bonus = Bonus.instantiate()
	# Spawna no topo, lado aleatório (dentro da tela)
	bonus.global_position = Vector2(randi() % 2 * 224 + 16, 20)
	if bonus.global_position.x > 117:
		bonus.direction = -1
	else:
		bonus.direction = 1
	self.add_child(bonus)
	bonus.connect("bonus_eliminado", Callable(get_parent(), "somar_bonus"))
