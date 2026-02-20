extends KinematicBody2D

export var speed = 400
export var jump = -400
export var gravity = 980

var velocity = Vector2.ZERO
var alive = true

func _ready():
	add_to_group("player")

func _process(_delta):
	if not alive:
		return
	
	var direction = 0
	if Input.is_action_pressed("move_left"):
		direction -=1
	if Input.is_action_pressed("move_right"):
		direction +=1
	
	velocity.x = direction * speed
	velocity.y += gravity * _delta
	
	if Input.is_action_just_pressed("move_up") && is_on_floor():
		velocity.y = jump
	
	velocity = move_and_slide(velocity, Vector2.UP)
