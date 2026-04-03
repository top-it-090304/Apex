extends RigidBody2D

@export var move_force = 3000
@export var jump_impulse = 550.0
@export var max_speed = 300.0
@export var is_flappy_bird = false
@export var air_rotation_speed = 6.0  # Максимальная скорость вращения при движении в воздухе
@export var rotation_accel = 1      # Шаг ускорения вращения в воздухе
@export var acceleration_speed = 5.0  # Скорость нарастания силы (чем меньше, тем плавнее)

var is_on_floor = false
var floor_normal = Vector2.UP
var current_force_multiplier = 0.0
var spawn_position

# Настройки Coyote Time
@export var coyote_time_duration = 0.15 # Время в секундах
var coyote_timer = 0.0

# Сенсорные кнопки (CanvasLayer на игроке): отступы и размер.
@export_group("Touch UI")
@export var touch_padding_left_extra: float = 50.0
@export var touch_padding_right_extra: float = 50.0
@export var touch_margin_ratio: float = 0.035
## Базовый margin от нижнего края (и база для расчёта; горизонтальные доп. — только поля выше).
@export var touch_margin_min: float = 22.0
@export var touch_margin_max: float = 64.0
@export var touch_spacing_ratio: float = 0.1 # Расстояние между левой и правой кнопкой
@export var touch_spacing_min: float = 72.0
@export var touch_spacing_max: float = 140.0
@export var touch_scale_reference_side: float = 1200.0
@export var touch_scale_min: float = 0.06
@export var touch_scale_max: float = 0.12
@export var touch_jump_scale_mul: float = 1.5 # Множитель для кнопки прыжка

func _ready():
	can_sleep = false
	spawn_position = global_position
	$AnimatedSprite2D.play()
	print(global_position)
	var loaded = SaveManager.load_slot(SaveManager.slot_save)
	if loaded["level"]["checkpoint_position"]["x"] !=0 or loaded["level"]["checkpoint_position"]["y"] !=0:
		var values = loaded["level"]["checkpoint_position"]
		global_position = Vector2(values["x"], values["y"])
	$Camera2D.reset_smoothing()
	_apply_adaptive_touch_ui()
	get_viewport().size_changed.connect(_apply_adaptive_touch_ui)
	
	
func _integrate_forces(state):
	if Input.is_action_just_pressed("flip_gravity"):
		flip_gravity()
	move(state)

func check_floor_contact(state):
	is_on_floor = false
	
	var gravity_dir = state.total_gravity.normalized()
	floor_normal = -gravity_dir 
	
	for i in range(state.get_contact_count()):
		var contact_normal = state.get_contact_local_normal(i)
		var dot = contact_normal.dot(gravity_dir)
		if dot < -0.5:
			is_on_floor = true
			floor_normal = contact_normal
			break


func move(state):
	var direction = Input.get_axis("move_left", "move_right")
	check_floor_contact(state)
	
	# Обновляем таймер Coyote Time
	if is_on_floor:
		coyote_timer = coyote_time_duration
	else:
		coyote_timer -= state.step
	
	# Горизонтальное движение через приложение силы
	if direction != 0:
		current_force_multiplier = move_toward(current_force_multiplier, 1.0, acceleration_speed * state.step)
		apply_central_force(Vector2(direction * move_force * current_force_multiplier, 0))
	else:
		current_force_multiplier = 0.0
		
	if not is_on_floor:
		var target_angular_vel = direction * air_rotation_speed
		
		state.angular_velocity = move_toward(
			state.angular_velocity, 
			target_angular_vel, 
			rotation_accel
		)
	
	# Ограничение скорости
	var vel = state.linear_velocity
	if abs(vel.x) > max_speed:
		vel.x = sign(vel.x) * max_speed
		state.linear_velocity = vel
	
	# Прыжок
	if is_flappy_bird:
		if Input.is_action_just_pressed("move_up"):
			var gravity_dir = sign(state.total_gravity.y)
			state.linear_velocity.y = -400 * gravity_dir
	elif Input.is_action_pressed("move_up") and coyote_timer > 0:
		state.linear_velocity.y = 0
		apply_central_impulse(Vector2(0, -jump_impulse))
		coyote_timer = 0


func _apply_adaptive_touch_ui():
	if not has_node("CanvasLayer/move_left") or not has_node("CanvasLayer/move_right") or not has_node("CanvasLayer/move_up"):
		return
	
	var safe_rect = _get_safe_area_rect()
	var safe_pos = safe_rect.position
	var safe_size = safe_rect.size
	
	var min_side = min(safe_size.x, safe_size.y)
	var ref: float = maxf(touch_scale_reference_side, 1.0)
	var button_scale: float = clamp(min_side / ref, touch_scale_min, touch_scale_max)
	var margin_bottom: float = clamp(min_side * touch_margin_ratio, touch_margin_min, touch_margin_max)
	var spacing: float = clamp(min_side * touch_spacing_ratio, touch_spacing_min, touch_spacing_max)
	
	var left_btn = $CanvasLayer/move_left
	var right_btn = $CanvasLayer/move_right
	var up_btn = $CanvasLayer/move_up
	
	left_btn.scale = Vector2(button_scale, button_scale)
	right_btn.scale = Vector2(button_scale, button_scale)
	up_btn.scale = Vector2(button_scale * touch_jump_scale_mul, button_scale * touch_jump_scale_mul)
	
	var left_x: float = safe_pos.x + margin_bottom + touch_padding_left_extra
	var bottom_y: float = safe_pos.y + safe_size.y - margin_bottom - left_btn.texture_normal.get_size().y * left_btn.scale.y
	left_btn.position = Vector2(left_x, bottom_y)
	right_btn.position = Vector2(left_btn.position.x + spacing + left_btn.texture_normal.get_size().x * left_btn.scale.x, bottom_y)
	var up_w: float = up_btn.texture_normal.get_size().x * up_btn.scale.x
	var up_h: float = up_btn.texture_normal.get_size().y * up_btn.scale.y
	var up_x: float = safe_pos.x + safe_size.x - margin_bottom - touch_padding_right_extra - up_w
	var up_bottom_y: float = safe_pos.y + safe_size.y - margin_bottom - up_h
	up_btn.position = Vector2(up_x, up_bottom_y)

func _get_safe_area_rect() -> Rect2:
	return get_viewport().get_visible_rect()


func flip_gravity():
	gravity_scale = gravity_scale * -1
	floor_normal = Vector2.DOWN if gravity_scale <0 else Vector2.UP
	jump_impulse = jump_impulse * -1
