extends CharacterBody2D

signal boss_killed
signal shoot_pattern(pattern_name)

@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var audio = $AudioStreamPlayer

const MAX_HP = 20
const SPEED = 40.0
const DESCENT_SPEED = 20.0

var hp = MAX_HP
var phase = 1
var pattern_timer = 0.0
var current_pattern = "spread"
var moving_left = true
var entered_screen = false
var target_y = 60

# Padrões de tiro
var patterns = {
	"spread": {"interval": 1.5, "shots": 5, "angle_spread": 40},
	"burst": {"interval": 2.5, "shots": 3, "burst_count": 3, "burst_delay": 0.3},
	"targeted": {"interval": 1.8, "shots": 1, "homing": true},
	"wall": {"interval": 3.0, "shots": 12, "angle_spread": 180},
}

func _ready():
	hp = MAX_HP
	phase = 1
	# Começa fora da tela (acima)
	global_position.y = -50
	
	# Adiciona ao grupo aliens para ser detectado pelo laser
	add_to_group("aliens")
	
	# Configura animação
	if animation_player and animation_player.has_animation("idle"):
		animation_player.play("idle")

func _physics_process(delta):
	if not entered_screen:
		# Desce até posição alvo
		global_position.y += DESCENT_SPEED * delta
		if global_position.y >= target_y:
			global_position.y = target_y
			entered_screen = true
		return
	
	# Movimento horizontal
	if moving_left:
		velocity.x = -SPEED
		if global_position.x <= 40:
			moving_left = false
	else:
		velocity.x = SPEED
		if global_position.x >= 214:
			moving_left = true
	
	move_and_slide()
	
	# Padrões de tiro
	pattern_timer += delta
	var pattern_data = patterns[current_pattern]
	if pattern_timer >= pattern_data["interval"]:
		pattern_timer = 0.0
		_execute_pattern(pattern_data)
	
	# Troca de fase baseada em HP
	if hp <= MAX_HP * 0.5 and phase == 1:
		phase = 2
		current_pattern = "burst"
		# Muda cor pra indicar fase 2
		sprite.modulate = Color(1, 0.5, 0)
	elif hp <= MAX_HP * 0.25 and phase == 2:
		phase = 3
		current_pattern = "wall"
		sprite.modulate = Color(1, 0, 0)

func _execute_pattern(pattern_data):
	var shots = pattern_data["shots"]
	var spread = pattern_data.get("angle_spread", 0)
	var burst_count = pattern_data.get("burst_count", 1)
	var burst_delay = pattern_data.get("burst_delay", 0.2)
	var homing = pattern_data.get("homing", false)
	
	for b in range(burst_count):
		if burst_count > 1:
			# Usa timer para bursts sequenciais
			get_tree().create_timer(b * burst_delay).timeout.connect(_fire_burst.bind(shots, spread, homing))
		else:
			_fire_burst(shots, spread, homing)

func _fire_burst(shots, spread, homing):
	emit_signal("shoot_pattern", {
		"position": global_position,
		"shots": shots,
		"spread": spread,
		"homing": homing,
		"source": "boss"
	})

func take_damage(amount):
	if hp <= 0:
		return
	hp -= amount
	
	print("BOSS: Tomou dano! HP: ", hp, "/", MAX_HP, " (dano: ", amount, ")")
	
	# Flash visual
	sprite.modulate = Color(1, 1, 1)
	get_tree().create_timer(0.1).timeout.connect(_restore_color)
	
	if hp <= 0:
		print("BOSS: Morreu!")
		die()

func _restore_color():
	if phase == 1:
		sprite.modulate = Color(1, 1, 1)
	elif phase == 2:
		sprite.modulate = Color(1, 0.5, 0)
	elif phase == 3:
		sprite.modulate = Color(1, 0, 0)

func die():
	emit_signal("boss_killed")
	queue_free()

func _draw():
	# Placeholder visual - retângulo grande com "olho"
	var _w = 80
	var _h = 40
	
	draw_rect(Rect2(-_w/2, -_h/2, _w, _h), Color(0.2, 0.1, 0.3))
	draw_rect(Rect2(-_w/2, -_h/2, _w, _h), Color(0.5, 0.2, 0.7), false, 2)
	
	# Olho
	var _eye_x = 0
	var _eye_y = -5
	draw_circle(Vector2(_eye_x, _eye_y), 8, Color(1, 0.2, 0.2))
	draw_circle(Vector2(_eye_x, _eye_y), 4, Color(0, 0, 0))
	
	# Barra de vida
	var bar_w = 70.0
	var bar_h = 6.0
	var bar_x = -bar_w/2.0
	var bar_y = _h/2.0 + 8.0
	draw_rect(Rect2(bar_x, bar_y, bar_w, bar_h), Color(0.3, 0.1, 0.1))
	draw_rect(Rect2(bar_x, bar_y, bar_w * (hp / MAX_HP), bar_h), Color(1, 0.2, 0.2))
