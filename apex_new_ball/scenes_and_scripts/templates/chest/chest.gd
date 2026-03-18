extends Area2D

var flag = false

func _ready() -> void:
	$AnimatedSprite2D.play()
	#region При запуске уровня проверяет был ли собран сундук, и не дает собрать его еще раз
	var loaded0 = SaveManager.load_slot(SaveManager.slot_save)
	var coords: Array = loaded0["level"]["chests_collected_coordinates_level"]
	for value in coords:
		if value["x"] == position.x and value["y"] == position.y:
			flag = true
			$AnimatedSprite2D.animation = "open"
			return
	#endregion

func _on_body_entered(_body: Node2D) -> void:
	#region При срабатывании сигнала открывает сундук, записывает инофрмацию в сейв
	if flag == false:
		Events.OPEN_THE_CHEST.emit($AnimatedSprite2D)
		var loaded0 = SaveManager.load_slot(SaveManager.slot_save)
		loaded0["player"]["score"] = loaded0["player"]["score"] + 500
		loaded0["level"]["chests_collected_coordinates_level"].append({
			"x": position.x,
			"y": position.y
		})
		SaveManager.save_slot(SaveManager.slot_save, loaded0)
		flag = true
	#endregion
