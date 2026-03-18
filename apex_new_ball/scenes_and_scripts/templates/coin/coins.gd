extends Area2D

var flag = false

func _ready() -> void:
	$AnimatedSprite2D.play()
	#region При запуске уровня проверяет была ли собрана монетка, и не дает собрать ее еще раз
	var loaded0 = SaveManager.load_slot(SaveManager.slot_save)
	var coords: Array = loaded0["level"]["coins_collected_coordinates_level"]
	for value in coords:
		if value["x"] == position.x and value["y"] == position.y:
			flag = true
			$AnimatedSprite2D.modulate.a = 0
			return
	#endregion

func _on_body_entered(_body: Node2D) -> void:
	#region При срабатывании сигнала собирает монету, записывает инофрмацию в сейв
	if flag == false:
		Events.COLLECTING_COINS.emit($AnimatedSprite2D)
		var loaded0 = SaveManager.load_slot(SaveManager.slot_save)
		loaded0["player"]["score"] = loaded0["player"]["score"] + 100
		loaded0["level"]["coins_collected_coordinates_level"].append({
			"x": position.x,
			"y": position.y
		})
		SaveManager.save_slot(SaveManager.slot_save, loaded0)
		flag = true
	#endregion
