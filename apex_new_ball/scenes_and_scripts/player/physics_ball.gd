extends RigidBody2D

# Параметры движения
@export var speed = 300.0
@export var acceleration = 2500.0
@export var friction = 350.0
@export var jump_force = 400.0

# Параметры гравитации
@export var gravity_direction = 1

# Режимы
@export var is_flappy_bird = false
@export var slide_on_slopes = true

# Параметры склонов
@export var min_slope_angle = 0.65
@export var max_slope_angle = 0.82

# Визуал
@export var ball_radius = 40000.0
@onready var sprite = $AnimatedSprite2D

# Жизни
@export var max_lives = 3
var current_lives = 3
var is_alive = true

# Внутренние переменные
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var velocity_x = 0.0
var is_on_ground = false
var can_jump = true
var last_position = Vector2.ZERO

func _ready() -> void:
	if sprite:
		sprite.play()
	add_to_group("player")
	gravity_scale = self.gravity_scale
	last_position = global_position
	linear_velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	# Получаем ввод
	var input_dir = Input.get_axis("move_left", "move_right")
	
	# Проверяем землю
	check_is_ground()
	
	# Движение по X
	if input_dir != 0:
		velocity_x = move_toward(velocity_x, input_dir * speed, acceleration * delta)
	else:
		velocity_x = move_toward(velocity_x, 0.0, friction * delta)
	
	# Прыжок
	if is_flappy_bird:
		if Input.is_action_just_pressed("move_up"):
			linear_velocity.y = -jump_force * gravity_direction
	else:
		if Input.is_action_pressed("move_up") and can_jump and is_on_ground:
			linear_velocity.y = -jump_force * gravity_direction
			can_jump = false
	
	# Гравитация
	var grav = gravity * gravity_scale * gravity_direction
	linear_velocity.y += grav * delta
	
	# Применяем скорость X
	linear_velocity.x = velocity_x
	
	# Вращение мяча
	var dist = global_position.x - last_position.x
	rotation += dist / ball_radius * gravity_direction
	last_position = global_position

func check_is_ground() -> void:
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2.DOWN * gravity_direction * 5.0
	)
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	is_on_ground = (result != null)
	
	if is_on_ground:
		can_jump = true

func take_damage() -> void:
	current_lives -= 1
	if current_lives <= 0:
		die()

func die() -> void:
	is_alive = false
	linear_velocity = Vector2.ZERO
	velocity_x = 0.0
	if sprite:
		sprite.visible = false

func respawn(spawn_pos: Vector2) -> void:
	global_position = spawn_pos
	linear_velocity = Vector2.ZERO
	velocity_x = 0.0
	current_lives = max_lives
	is_alive = true
	if sprite:
		sprite.visible = true
	last_position = global_position

func get_lives() -> int:
	return current_lives
