extends Control

@onready var audio = $AudioStreamPlayer

# Labels da sequência de boot
@onready var lbl_init = $"TitleContainer#LabelInit"
@onready var lbl_core = $"TitleContainer#LabelCore"
@onready var lbl_firewall = $"TitleContainer#LabelFirewall"
@onready var lbl_defense = $"TitleContainer#LabelDefense"

@onready var sep1 = $"TitleContainer#Separator1"

@onready var lbl_warning = $"TitleContainer#LabelWarning"
@onready var lbl_unknown = $"TitleContainer#LabelUnknown"
@onready var lbl_virus = $"TitleContainer#LabelVirus"
@onready var lbl_multiple = $"TitleContainer#LabelMultiple"
@onready var lbl_attack = $"TitleContainer#LabelAttack"

@onready var sep2 = $"TitleContainer#Separator2"

@onready var lbl_prompt = $"TitleContainer#LabelPrompt"

@onready var btn_start = $VBoxContainer/ButtonStart


# Estado da intro
var intro_finalizada: bool = false
var intro_pulada: bool = false

# Controle do texto piscando
var timer_piscar: float = 0.0
var prompt_visivel: bool = true

# Evita apertar Enter várias vezes
var iniciando_jogo: bool = false


func _ready():
	esconder_intro()

	# Inicia a sequência de boot
	executar_intro()


func _process(delta):
	if not intro_finalizada:
		return

	# Faz o PRESS ENTER piscar
	timer_piscar += delta

	if timer_piscar >= 0.65:
		timer_piscar = 0.0
		prompt_visivel = !prompt_visivel
		lbl_prompt.visible = prompt_visivel


# =========================================================
# INTRO
# =========================================================

func executar_intro():
	# INITIALIZING SYSTEM...
	lbl_init.visible = true

	await esperar(0.8)

	if intro_pulada:
		return

	# [OK] CORE ONLINE
	mostrar_com_som(lbl_core)

	await esperar(0.5)

	if intro_pulada:
		return

	# [OK] FIREWALL ONLINE
	mostrar_com_som(lbl_firewall)

	await esperar(0.5)

	if intro_pulada:
		return

	# [OK] DEFENSE PROTOCOL ONLINE
	mostrar_com_som(lbl_defense)

	await esperar(0.5)

	if intro_pulada:
		return

	# Separador
	sep1.visible = true

	await esperar(0.6)

	if intro_pulada:
		return

	# WARNING!
	mostrar_com_som(lbl_warning)

	await esperar(0.5)

	if intro_pulada:
		return

	# UNKNOWN PROCESS DETECTED
	lbl_unknown.visible = true

	await esperar(0.5)

	if intro_pulada:
		return

	# > VIRUS.EXE
	mostrar_com_som(lbl_virus)

	await esperar(0.5)

	if intro_pulada:
		return

	# MULTIPLE THREATS DETECTED
	lbl_multiple.visible = true

	await esperar(0.5)

	if intro_pulada:
		return

	# SYSTEM UNDER ATTACK...
	mostrar_com_som(lbl_attack)

	await esperar(0.4)

	if intro_pulada:
		return

	# Segundo separador
	sep2.visible = true

	await esperar(0.5)

	if intro_pulada:
		return

	finalizar_intro()


# =========================================================
# CONTROLE DOS ELEMENTOS
# =========================================================

func esconder_intro():
	lbl_init.visible = false
	lbl_core.visible = false
	lbl_firewall.visible = false
	lbl_defense.visible = false

	sep1.visible = false

	lbl_warning.visible = false
	lbl_unknown.visible = false
	lbl_virus.visible = false
	lbl_multiple.visible = false
	lbl_attack.visible = false

	sep2.visible = false

	lbl_prompt.visible = false
	btn_start.visible = false


func finalizar_intro():
	intro_finalizada = true

	# Mostra tudo caso o jogador tenha pulado a intro
	lbl_init.visible = true
	lbl_core.visible = true
	lbl_firewall.visible = true
	lbl_defense.visible = true

	sep1.visible = true

	lbl_warning.visible = true
	lbl_unknown.visible = true
	lbl_virus.visible = true
	lbl_multiple.visible = true
	lbl_attack.visible = true

	sep2.visible = true

	lbl_prompt.visible = true

	btn_start.visible = true
	btn_start.grab_focus()

	prompt_visivel = true
	timer_piscar = 0.0


func pular_intro():
	if intro_finalizada:
		return

	intro_pulada = true

	finalizar_intro()


func mostrar_com_som(label):
	label.visible = true
	tocar_som()


func tocar_som():
	if audio:
		audio.play()


func esperar(tempo: float):
	await get_tree().create_timer(tempo).timeout


# =========================================================
# INICIAR JOGO
# =========================================================

func iniciar_jogo():
	if iniciando_jogo:
		return

	iniciando_jogo = true

	tocar_som()

	# Pequeno delay opcional para o som do Enter tocar
	await esperar(0.15)

	get_tree().change_scene_to_file("res://cenas/main.tscn")


func _on_button_start_pressed():
	iniciar_jogo()


# =========================================================
# INPUT
# =========================================================

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and not event.echo:

			if event.keycode == KEY_ENTER:

				# Se a animação ainda estiver acontecendo,
				# Enter mostra tudo instantaneamente
				if not intro_finalizada:
					pular_intro()

				# Se já terminou, Enter inicia o jogo
				else:
					iniciar_jogo()
