extends RigidBody2D

@export var move_force = 1500.0
@export var jump_force = 500.0
@export var max_speed = 400.0

var is_on_floor = false
var floor_normal = Vector2.UP

func _ready():
	can_sleep = false  # Запрещаем засыпать

func _integrate_forces(state):
	move(state)

func check_floor_contact(state):
	is_on_floor = false
	floor_normal = Vector2.UP
	
	if state.get_contact_count() > 0:
		for i in range(state.get_contact_count()):
			var contact_normal = state.get_contact_local_normal(i)
			if contact_normal.y < -0.5:
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
	#if Input.is_action_pressed("move_up") and is_on_floor:
		## Прыгаем по нормали пола (работает на наклонах!)
		#apply_central_impulse(-floor_normal * jump_force)
	
