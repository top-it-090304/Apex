extends CharacterBody2D

@export var speed = 300.0
@export var acceleration = 5000.0 #разгон
@export var friction = 500.0 #торможение
@export var jump = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var gravity_scale = 1.0 #замедление падения
@export var gravity_direction = 1 #направление гравитации
@export var is_flappy_bird = false
@export var slide_on_slopes = true
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var alive = true
var last_position : Vector2
@export var radius : float = 40 # Радиус мяча в пикселях

func _ready() -> void:
	velocity = Vector2.ZERO
	add_to_group("player")
	$AnimatedSprite2D.play()
	up_direction = Vector2.UP * gravity_direction
	floor_max_angle = deg_to_rad(60)
	floor_constant_speed = false
	floor_stop_on_slope = not slide_on_slopes
	last_position = global_position
	
func _physics_process(delta: float) -> void:
	if not alive:
		return
		
	up_direction = Vector2.UP * gravity_direction
	
	
	# Для реализации вращения
	var distance_moved = global_position.x - last_position.x
	rotation += distance_moved / radius * gravity_direction
	last_position = global_position
	
	
	velocity.y += delta * gravity * gravity_scale * gravity_direction
	
	var direction = Input.get_axis("move_left", "move_right")
	#if Input.is_action_pressed("move_left"):
		#animated_sprite.flip_h = false
	#if Input.is_action_pressed("move_right"):
		#animated_sprite.flip_h = true
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)
	
	if is_flappy_bird != true:
		if Input.is_action_pressed("move_up") && (is_on_ceiling() && gravity_direction == -1 || is_on_floor() && gravity_direction == 1):
			velocity.y = jump * gravity_direction
	elif Input.is_action_just_pressed("move_up"):
		velocity.y = jump * gravity_direction
	
	if slide_on_slopes and is_on_floor():
		var normal = get_floor_normal()
		if normal != up_direction && direction == 0:
			var sloper_direction = 1 if normal.x > 0 else -1
			velocity.x = move_toward(velocity.x, sloper_direction * speed, acceleration * delta * 0.5)
	
	move_and_slide()
