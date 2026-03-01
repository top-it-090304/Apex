extends CharacterBody2D

@export var speed = 300.0 													#скорость
@export var acceleration = 2500.0 											#разгон
@export var friction =350.0 												#торможение
@export var jump = -400.0 													#прыжок
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") 	#гравитация
@export var gravity_scale = 1.0 											#замедление падения
@export var gravity_direction = 1 											#направление гравитации
@export var is_flappy_bird = false 											#бесконечный прыжок
@export var slide_on_slopes = true 											#скатывание
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D 			#анимация
var alive = true 															#жизнь
@export var number_of_lives = 3 											#количество жизней
var last_position : Vector2 												#последнее положение
@export var radius : float = 40 											# Радиус мяча в пикселях

func _ready() -> void:
	velocity = Vector2.ZERO
	add_to_group("player")
	$AnimatedSprite2D.play()
	floor_max_angle = deg_to_rad(45)
	floor_constant_speed = false
	floor_stop_on_slope = not slide_on_slopes
	last_position = global_position
	
func _physics_process(delta: float) -> void:
	if not alive:
		return
	
	var direction = Input.get_axis("move_left", "move_right")
	rotation_ball()
	move_on_click(direction, delta)
	jump_and_flappy_bird(delta)
	slope_on_slope(direction, delta)
	move_and_slide()

func jump_and_flappy_bird(delta):
	velocity.y += delta * gravity * gravity_scale * gravity_direction
	if is_flappy_bird != true:
		if Input.is_action_pressed("move_up") && (is_on_ceiling() && gravity_direction == -1 || is_on_floor() && gravity_direction == 1):
			velocity.y = jump * gravity_direction
	elif Input.is_action_just_pressed("move_up"):
		velocity.y = jump * gravity_direction
func move_on_click(direction, delta) -> int:
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	return direction
func rotation_ball():
	var distance_moved = global_position.x - last_position.x
	rotation += distance_moved / radius * gravity_direction
	last_position = global_position
func slope_on_slope(direction, delta):
	if slide_on_slopes and is_on_floor():
		var normal = get_floor_normal()
		var floor_angle = get_floor_angle()
		var is_valid_slope = abs(floor_angle) > 0.65 and abs(floor_angle) < 0.82
		var sloper_direction = 1 if normal.x > 0 else -1
		if is_valid_slope && direction == 0:
			friction = 5000
			velocity.x = move_toward(velocity.x, sloper_direction * speed , acceleration * delta)
			velocity.y = move_toward(velocity.y, jump * -gravity_direction, acceleration * delta / 0.25)
		var is_valid_y = abs(floor_angle) > 0.25 && abs(floor_angle) < 0.7
		if is_valid_y && direction == 0:
			velocity.x = move_toward(velocity.x, sloper_direction * speed / 2.8, acceleration * delta)
		else:
			friction = 350.0
