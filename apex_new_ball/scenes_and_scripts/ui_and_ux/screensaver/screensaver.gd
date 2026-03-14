extends Node2D

#timers
@export var timer = 0
@export var timer1 = 0
@export var timer2 = 0

#flags
@export var flag1 = false
@export var flag2 = false
@export var flag2_5 = false
@export var flag3 = false

func _ready() -> void:
	print("=== READY STARTED ===")
	$black_canvas.modulate = Color.BLACK
	$button/Label1.text = "tap to play"
	$button/Label1.add_theme_font_size_override("font_size", 72)
	$button/Label1.modulate.a = 0
	$button/Label2.modulate.a = 0
	
func _process(_delta: float) -> void:
	#сброс прозрачности
	if flag1 != true:
		timer1 += 1
		if timer1 >= 4 && $black_canvas.modulate.a > 0:
			$black_canvas.modulate.a -= 0.04
			timer1 = 0
			if $black_canvas.modulate.a <= 0:
				flag1 = true
	
	if flag1 == true && flag2 == false:
		timer += 1
		if timer >= 2:
			if $button/Label1.modulate.a < 1:
				$button/Label1.modulate.a += 0.1
				if $button/Label1.modulate.a >= 1:
					flag2 = true
				
			if $button/Label2.modulate.a < 0.7:
				$button/Label2.modulate.a += 0.07
				
			timer = 0
	
	if flag2_5 == true:
		timer2 += 1
		print($black_canvas.modulate.a)
		if timer2 >= 4 && $black_canvas.modulate.a <= 1:
			$black_canvas.modulate.a += 0.06
			timer2 = 0
			if $black_canvas.modulate.a >= 1:
				flag3 = true
				
		if timer2 >= 2 && $button/Label1.modulate.a > 0:
			$button/Label1.modulate.a -= 0.1
			
		if timer2 >= 2 && $button/Label1.modulate.a > 0:
			$button/Label2.modulate.a -= 0.1
	
	if flag3 == true:
		get_tree().change_scene_to_file("res://scenes_and_scripts/ui_and_ux/menu/menu.tscn")
	
func _input(event: InputEvent) -> void:
	# Проверяем нажатие мышки или сенсора
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:  # Когда нажали (не отпустили)
			print("🎯 НАЖАТО НА ЭКРАН!")
			_on_screen_pressed()
	
func _on_screen_pressed() -> void:
	if flag2 == true:
		flag2_5 = true
