extends Control

@onready var adn_count_label: Label = %ADNcountLabel
@onready var button_amoeba: TextureButton = %ButtonAmoeba
@onready var adn_per_second_label: Label = %ADNperSecondLabel
@onready var amoeba_idle_animation: AnimationPlayer = $AmoebaIdleAnimation
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var purchase_sound: AudioStreamPlayer = $PurchaseSound

@onready var enhancement_buttons_container: VBoxContainer = %EnhancementButtonsContainer
@onready var scroll_container_enhancement: ScrollContainer = %ScrollContainerEnhancement

const ENHANCEMENT_BUTTON = preload("res://enhancement_button.tscn")
const EVOLUTION_BUTTON = preload("res://evolution_button.tscn")

@export var generators: Array[Enhancement] = []
@export var evolutions: Array[Evolution] = []

# --- Estado del juego ---
var adn_count: float = 0.0
var adn_per_second: float = 0.0
var all_time_adn: float = 0.0

# --- Stats de click ---
var click_value: int = 1
var click_critic_value: float = 3.0
var click_critic_prob: float = 0.1

# --- Tweens de animación ---
var _bounce_tween: Tween
var _press_tween: Tween


# =====================
# INICIALIZACIÓN
# =====================

func _ready() -> void:
	amoeba_idle_animation.play("amoeba_idle")
	for generator in generators:
		if generator.unlocked or not generator.mysterious:
			create_enhancement_button(generator)
	_update_enhancement_buttons()

# =====================
# LOOP PRINCIPAL
# =====================

func _process(delta: float) -> void:
	# Producción pasiva de ADN
	adn_count += adn_per_second * delta
	all_time_adn += adn_per_second * delta
	adn_count_label.text = Utilities.number_format(adn_count)
	adn_per_second_label.text = Utilities.number_format(adn_per_second)
	check_unlocks()

	# Detección de click sobre la ameba
	if Input.is_action_just_pressed("amoeba_click"):
		var mouse_pos = get_global_mouse_position()
		if button_amoeba.get_global_rect().has_point(mouse_pos):
			_animate_amoeba_press()
			_register_click()

# =====================
# LÓGICA DE CLICK
# =====================

func _register_click() -> void:
	var multiplier: float = 1.0
	if randf() > (1.0 - click_critic_prob):
		multiplier = click_critic_value
	adn_count += click_value * multiplier
	all_time_adn += click_value * multiplier
	_update_enhancement_buttons()
	_animate_amoeba_bounce()
	_spawn_click_particle()
	_spawn_click_number(multiplier)
	click_sound.play(0.0)

# =====================
# ANIMACIONES
# =====================

func _animate_amoeba_press() -> void:
	if _press_tween: _press_tween.kill()
	_press_tween = create_tween()
	_press_tween.set_ease((_press_tween.EASE_IN))
	_press_tween.set_trans(_press_tween.TRANS_SINE)
	_press_tween.tween_property(button_amoeba, "scale", Vector2(0.975,0.975), 0.08)


func _animate_amoeba_bounce() -> void:
	if _bounce_tween: _bounce_tween.kill() 
	_bounce_tween = create_tween()
	_bounce_tween.set_ease(_bounce_tween.EASE_OUT)
	_bounce_tween.set_trans(_bounce_tween.TRANS_SINE)
	_bounce_tween.tween_property(button_amoeba, "scale", Vector2(1.025,1.025), 0.1)
	_bounce_tween.set_ease(_bounce_tween.EASE_OUT)
	_bounce_tween.set_trans(_bounce_tween.TRANS_ELASTIC)
	_bounce_tween.tween_property(button_amoeba, "scale", Vector2(1.0,1.0), 0.9)

# =====================
# EFECTOS VISUALES DE CLICK
# =====================

func _spawn_click_particle() -> void:
	var particle := TextureRect.new()
	particle.texture = preload("res://Assets/Textures/ADNversion4.png")
	particle.stretch_mode = TextureRect.STRETCH_SCALE
	particle.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	particle.size = Vector2(45.0,45.0)
	particle.position = button_amoeba.get_global_mouse_position() + Vector2(randf_range(-5.0, 5.0), 0.0)
	add_child(particle)
	var random_angle := randf_range(0, 2*PI)
	var random_direction = Vector2(cos(random_angle), sin(random_angle))
	var random_distance = randf_range(100.0, 180.0)
	var final_position = random_direction * random_distance + particle.position
	var ParticleTween := create_tween()
	ParticleTween.set_parallel()
	ParticleTween.set_ease(Tween.EASE_OUT)
	ParticleTween.set_trans(Tween.TRANS_SINE)
	ParticleTween.tween_property(particle,"position",final_position,1.0)
	ParticleTween.tween_property(particle,"modulate:a",0.0,1.0)
	ParticleTween.finished.connect(particle.queue_free)


func _spawn_click_number(multiplier: float) -> void:
	var number_label := Label.new()
	number_label.text = "+" + Utilities.number_format(click_value * multiplier)
	var label_settings = LabelSettings.new()
	label_settings.font = preload("res://Assets/Fonts/ShareTechMono-Regular.ttf")
	if multiplier > 1.0:
		label_settings.font_color = Color("#ff6644")
		label_settings.font_size = 34
		number_label.text = "+" + Utilities.number_format(click_value * multiplier) + " crit!"
	else:
		label_settings.font_color = Color("#f0c96a")
		label_settings.font_size = 28
	label_settings.outline_color = Color("#1a2a4a")
	label_settings.outline_size = 3
	number_label.label_settings = label_settings
	number_label.position = button_amoeba.get_global_mouse_position() + Vector2(randf_range(-5.0, 5.0), 0.0)
	add_child(number_label)
	var labelTween := create_tween()
	labelTween.set_parallel()
	labelTween.set_ease(Tween.EASE_OUT)
	labelTween.set_trans(Tween.TRANS_SINE)
	labelTween.tween_property(number_label,"position:y", number_label.position.y - 150.0,1.0)
	labelTween.tween_property(number_label,"modulate:a", 0.0,1.0)
	labelTween.finished.connect(number_label.queue_free)


# =====================
# MEJORAS Y EVOLUCIONES
# =====================

func _update_enhancement_buttons() -> void:
	for generator in generators:
		if generator.button:
			generator.button.update_button(generator)


func _on_enhancement_purchased(generator: Enhancement) -> void:
	adn_count -= generator.cost
	if generator.type == "Generator":
		adn_per_second += generator.value
	elif generator.type == "Click":
		click_value += 1
		generator.value += 1
	generator.count += 1
	generator.cost *= 1.15
	purchase_sound.play()
	_update_enhancement_buttons()


func create_enhancement_button(enhancement: Enhancement)-> void:
	var new_enhancement_button = ENHANCEMENT_BUTTON.instantiate()
	enhancement_buttons_container.add_child(new_enhancement_button)
	new_enhancement_button.button_setup(enhancement)
	new_enhancement_button.button.pressed.connect(_on_enhancement_purchased.bind(enhancement))
	enhancement.button = new_enhancement_button


func create_evolution_button(evolution: Evolution)-> void:
	var new_evolution_button = EVOLUTION_BUTTON.instantiate()
	enhancement_buttons_container.add_child(new_evolution_button)
	enhancement_buttons_container.move_child(new_evolution_button, 0)
	new_evolution_button.button_setup(evolution)
	new_evolution_button.button.pressed.connect(_on_evolution_purchased.bind(evolution))
	evolution.button = new_evolution_button


func _on_evolution_purchased(evolution: Evolution) -> void:
	adn_count -= evolution.cost
	adn_per_second *= evolution.multiplier
	for generator in generators:
		generator.value *= evolution.multiplier
	evolution.purchased = true
	evolution.active = false
	evolution.button.queue_free()
	button_amoeba.texture_normal = evolution.icon
	purchase_sound.play()
	_update_enhancement_buttons()

# =====================
# SISTEMA DE DESBLOQUEOS
# =====================

func check_unlocks():
	# Solo puede haber una evolución visible a la vez
	var any_evolution_visible:= false
	for evolution in evolutions:
		if evolution.active: any_evolution_visible = true

	for generator in generators:
		if generator.button == null and adn_count >= generator.visibility_cost:
			create_enhancement_button(generator)
			generator.button.set_hidden(true)
		elif generator.button and generator.mysterious and adn_count >= generator.unlock_cost:
			generator.mysterious = false
			generator.button.set_hidden(false)
		if generator.button:
			generator.button.set_disabled(adn_count < generator.cost)

	for evolution in evolutions:
		if not any_evolution_visible and evolution.button == null and all_time_adn >= evolution.visibility_cost and not evolution.purchased:
			create_evolution_button(evolution)
			break
		if evolution.button:
			evolution.button.set_disabled(adn_count < evolution.cost)
