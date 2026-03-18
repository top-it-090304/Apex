extends Node2D

func _ready() -> void:
	$black_canvas.modulate = Color.BLACK
	$button/Label1.text = "tap to play"
	$button/Label1.add_theme_font_size_override("font_size", 72)
	$button/Label1.modulate.a = 0
	$button/Label2.modulate.a = 0
	
	var tween = create_tween()
	tween.tween_property($black_canvas, "modulate:a", 0.0, 1.5)
	tween.tween_callback(_show_button)

func _show_button():
	var tween = create_tween().set_parallel(true)
	tween.tween_property($button/Label1, "modulate:a", 1.0, 0.5)
	tween.tween_property($button/Label2, "modulate:a", 0.7, 0.5)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			_on_screen_pressed()

func _on_screen_pressed() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property($black_canvas, "modulate:a", 1.0, 0.8)
	tween.tween_property($button/Label1, "modulate:a", 0.0, 0.4)
	tween.tween_property($button/Label2, "modulate:a", 0.0, 0.4)
	
	tween.set_parallel(false)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes_and_scripts/ui_and_ux/menu/menu.tscn"))
	
