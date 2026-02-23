extends CharacterBody2D

@export var speed = 300.0
@export var acceleration = 2500.0  # Разгон
@export var friction = 4000.0      # Торможение
@export var jump_velocity = 500.0
@export var gravity_scale = 1.0 as float # Будет использоваться для замедления гравитации при попадании в воду
@export var is_flappy_bird = 0
var default_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var gravity_direction = 1 # 1 — вниз, -1 — вверх
var alive = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	velocity = Vector2.ZERO
	#up_direction = Vector2.UP
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if not alive:
		return

	velocity.y += default_gravity * gravity_scale * gravity_direction * delta
	
	if (not is_flappy_bird):
		if Input.is_action_pressed("move_up"):
			if (gravity_direction == 1 and is_on_floor()) or (gravity_direction == -1 and is_on_ceiling()):
				velocity.y = -jump_velocity * gravity_direction
	else:
		if Input.is_action_just_pressed("move_up"):
			if (gravity_direction == 1) or (gravity_direction == -1):
				velocity.y = -jump_velocity * gravity_direction

	# Движение влево/вправо
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

	move_and_slide()


func flip_gravity():
	gravity_direction *= -1
	up_direction = Vector2.UP * gravity_direction
	
	# Переворачиваем спрайт
	if gravity_direction == -1:
		animated_sprite.flip_v = true
	else:
		animated_sprite.flip_v = false
