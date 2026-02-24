extends Node2D

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes_and_scripts/levels/level_0.tscn")
