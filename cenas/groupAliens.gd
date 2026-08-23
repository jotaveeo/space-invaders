extends Node

var Alien = preload("res://cenas/alien.tscn")

var lista_aliens = []

func  _ready():
	for j in range(4):
		lista_aliens.append([])
		for i in range(8):
			var alien = Alien.instantiate()
			alien.global_position = Vector2(50+20*i, 40+20*j)
			self.add_child(alien)
			lista_aliens[j].append(alien)
			alien.connect("alien_eliminado", Callable(self, "eliminar_alien"))
			
func eliminar_alien(a):
	for fila in lista_aliens:
		if a in fila:
			fila.erase(a)
