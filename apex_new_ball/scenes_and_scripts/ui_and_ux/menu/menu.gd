extends Node2D

var timer = 0
@export var flag1 = false

func _ready():
	print("=== MENU STARTED ===")
	$black_canvas.modulate = Color.BLACK
	

func _process(_delta):
	if flag1 != true:
		timer += 10
		if timer >= 40 && $black_canvas.modulate.a > 0:
			$black_canvas.modulate.a -= 0.02
			timer = 0

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes_and_scripts/levels/level_0.tscn")
