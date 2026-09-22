extends CharacterBody2D

@export var laser = preload("res://cenas/laser.tscn")

@onready var ptoLaser = $pontoDoLaser
@onready var timer_disparar = $TimerDisparo
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D

const SPEED = 100.0
const MAX_VIDAS = 3
const INVULNERABILIDADE_TEMPO = 2.0

var vidas = MAX_VIDAS
var pode_disparar = true
var invulneravel = false
var pisca_timer = 0.0
var invuln_timer = 0.0
const PISCA_INTERVALO = 0.1

signal vida_perdida(vidas_restantes)
signal game_over

func _ready():
	vidas = MAX_VIDAS
	emit_signal("vida_perdida", vidas)

func _physics_process(_delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if Input.is_action_just_pressed("shoot") and pode_disparar == true:
		var l = laser.instantiate()
		l.global_position = ptoLaser.global_position
		get_parent().add_child(l)
		pode_disparar = false
		timer_disparar.start()
		$AudioStreamPlayer.play()
		
	# Pisca durante invulnerabilidade
	if invulneravel:
		pisca_timer += _delta
		invuln_timer += _delta
		if pisca_timer >= PISCA_INTERVALO:
			pisca_timer = 0.0
			sprite.visible = not sprite.visible
		if invuln_timer >= INVULNERABILIDADE_TEMPO:
			invulneravel = false
			invuln_timer = 0.0
			pisca_timer = 0.0
			sprite.visible = true
	
	move_and_slide()
	
func _on_timer_disparo_timeout():
	pode_disparar = true
	
func destruir():
	animation_player.play("destruido")
	$AudioStreamPlayer.play()
	
func eliminado():
	if !self.is_queued_for_deletion():
		perder_vida()
		
func perder_vida():
	if invulneravel:
		return
	vidas -= 1
	emit_signal("vida_perdida", vidas)
	
	if vidas <= 0:
		emit_signal("game_over")
		get_tree().change_scene_to_file("res://cenas/gameover.tscn")
	else:
		# Respawn com invulnerabilidade
		invulneravel = true
		pisca_timer = 0.0
		invuln_timer = 0.0
		global_position = Vector2(127, 240)
		animation_player.play("vivo")
		#get_parent().remove_child(self)
		#queue_free()
