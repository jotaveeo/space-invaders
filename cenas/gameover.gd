extends Node2D

@onready var btn_reiniciar = $botaoreiniciar
@onready var audio = $AudioStreamPlayer

var reiniciando := false


func _ready():
	btn_reiniciar.grab_focus()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_ENTER:
				reiniciar_jogo()


func _on_botaoreiniciar_pressed():
	reiniciar_jogo()


func reiniciar_jogo():
	if reiniciando:
		return

	reiniciando = true

	if audio:
		audio.play()

	await get_tree().create_timer(0.15).timeout

	if get_tree():
		get_tree().change_scene_to_file("res://cenas/main.tscn")
