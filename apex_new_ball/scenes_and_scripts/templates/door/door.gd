extends Area2D

var flag = false

func _ready() -> void:
	$AnimatedSprite2D.play()

func _on_body_entered(_body: Node2D) -> void:
	var loads = SaveManager.load_slot(SaveManager.slot_save)
	var total = loads["level"]["flags_total"]
	var collected = loads["level"]["flags_collected"]
	if int(total) == int(collected):
		Events.OPEN_THE_DOOR.emit($AnimatedSprite2D)
		await get_tree().create_timer(0.5).timeout
		loads["level"]["scene_number"] += 1
		loads["level"]["current_scene"] = "res://scenes_and_scripts/levels/level%d.tscn" % loads["level"]["scene_number"]
		SaveManager.save_slot(SaveManager.slot_save, loads)
		if loads["level"]["scene_number"] > 5:
			get_tree().change_scene_to_file("res://scenes_and_scripts/ui_and_ux/menu/menu.tscn")
		else:
			if ResourceLoader.exists(loads["level"]["current_scene"]):
				get_tree().change_scene_to_file(loads["level"]["current_scene"])
			else:
				get_tree().change_scene_to_file("res://scenes_and_scripts/ui_and_ux/menu/menu.tscn")
		flag = true
	pass
