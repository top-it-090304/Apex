extends RigidBody2D

@export var move_force = 1500.0
@export var jump_impulse = 500.0
@export var max_speed = 400.0
@export var is_flappy_bird = true
#var floor_normal = Vector2.UP

#var gravity_inverted = false  # Флаг инвертированной гравитации

var is_on_floor = false
var is_on_ceiling = false
var is_on_wall = false
var floor_normal = Vector2.UP
var ceiling_normal = Vector2.ZERO


func _ready():
	can_sleep = false  # Запрещаем засыпать	
	$AnimatedSprite2D.play()
	#flip_gravity()   

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
	
	# Просто применяем силу
	if direction != 0:
		apply_central_force(Vector2(direction * move_force, 0))
	
	# Ограничение скорости
	var vel = state.linear_velocity
	if abs(vel.x) > max_speed:
		vel.x = sign(vel.x) * max_speed
		state.linear_velocity = vel
	
	# Прыжок
	if Input.is_action_pressed("move_up") and is_on_floor:
		apply_central_impulse(Vector2(0, -jump_impulse))
	

func flip_gravity():
	gravity_scale = gravity_scale * -1
	floor_normal = Vector2.DOWN if gravity_scale < 0  else Vector2.UP
	jump_impulse = jump_impulse * -1
