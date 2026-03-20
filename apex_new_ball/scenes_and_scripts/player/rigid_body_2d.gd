extends RigidBody2D

@export var move_force = 3000
@export var jump_impulse = 500.0
@export var max_speed = 300.0
@export var is_flappy_bird = false
@export var air_rotation_speed = 5.0  # Максимальная скорость вращения при движении в воздухе
@export var rotation_accel = 0.5      # Шаг ускорения вращения в воздухе

var is_on_floor = false
var floor_normal = Vector2.UP
var spawn_position

# Настройки Coyote Time
@export var coyote_time_duration = 0.15 # Время в секундах
var coyote_timer = 0.0

func _ready():
	can_sleep = false
	spawn_position = global_position
	$AnimatedSprite2D.play()
	print(global_position)
	var loaded = SaveManager.load_slot(SaveManager.slot_save)
	if loaded["level"]["checkpoint_position"]["x"] != 0 or loaded["level"]["checkpoint_position"]["y"] != 0:
		var values = loaded["level"]["checkpoint_position"]
		global_position = Vector2(values["x"], values["y"])
	$Camera2D.reset_smoothing()

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
		apply_central_force(Vector2(direction * move_force, 0))
		
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


func flip_gravity():
	gravity_scale = gravity_scale * -1
	floor_normal = Vector2.DOWN if gravity_scale < 0  else Vector2.UP
	jump_impulse = jump_impulse * -1
