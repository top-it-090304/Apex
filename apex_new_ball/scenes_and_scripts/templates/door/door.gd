extends Area2D

var flag = false

func _ready() -> void:
	$AnimatedSprite2D.play()

func _on_body_entered(_body: Node2D) -> void:
	# Блокируем повторный вход сразу, до await, чтобы не было двойной смены сцены
	if flag:
		return
	
	var loads = GameManager.local_save
	var total = loads["level"]["flags_total"]
	var collected = loads["level"]["flags_collected"]
	if int(total) == int(collected):
		flag = true  # ставим до await, иначе мяч может войти ещё раз за 0.5с
		SFXManager.play_sfx(SFXManager.DOOR, SFXManager.DOOR_VOLUME)
		Events.OPEN_THE_DOOR.emit($AnimatedSprite2D)
		PycoLog.log_event_by_type("level_complete", {"level": loads["level"]["scene_number"], "score": loads["player"]["score"]})
		await get_tree().create_timer(0.5).timeout
		loads["level"]["scene_number"] += 1
		loads["level"]["flags_collected"] = 0
		loads["level"]["flags_total"] = 0
		loads["level"]["checkpoint_position"] = {"x": 0, "y": 0}
		loads["level"]["flags_collected_coordinates_level"] = []
		loads["level"]["coins_collected_coordinates_level"] = []
		loads["level"]["chests_collected_coordinates_level"] = []
		loads["level"]["current_scene"] = "res://scenes_and_scripts/levels/level_%d.tscn" % loads["level"]["scene_number"]
		SaveManager.save(GameManager.local_save)
		if loads["level"]["scene_number"] > 5:
			PycoLog.log_event_by_type("game_win", {"score": loads["player"]["score"]})
			Events.SHOW_LEADERBOARD_SUBMIT.emit(loads["player"]["score"])
		else:
			if ResourceLoader.exists(loads["level"]["current_scene"]):
				get_tree().change_scene_to_file(loads["level"]["current_scene"])
			else:
				Events.SHOW_LEADERBOARD_SUBMIT.emit(loads["player"]["score"])
