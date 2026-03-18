extends Area2D

var flag = false

func _ready() -> void:
	$AnimatedSprite2D.play()
	#region При запуске уровня проверяет был ли активирован флаг, и не дает сделать это ее еще раз
	var loaded0 = SaveManager.load_slot(SaveManager.slot_save)
	var coords: Array = loaded0["level"]["flags_collected_coordinates_level"]
	for value in coords:
		if value["x"] == position.x and value["y"] == position.y:
			flag = true
			$AnimatedSprite2D.animation = "flag"
			return
	#endregion

func _on_body_entered(_body: Node2D) -> void:
	#region При срабатывании сигнала активирует флаг, записывает инофрмацию в сейв и ставит чекпоинт на последнем собранном флаге
	if  flag == false:
		Events.TOUCHING_THE_FLAG.emit($AnimatedSprite2D)
		var loaded0 = SaveManager.load_slot(SaveManager.slot_save)
		loaded0["level"]["flags_collected"] = loaded0["level"]["flags_collected"] + 1
		loaded0["level"]["flags_collected_coordinates_level"].append({
			"x": position.x,
			"y": position.y
		}) 
		loaded0["level"]["checkpoint_position"] = {
			"x": position.x,
			"y": position.y
		}
		SaveManager.save_slot(SaveManager.slot_save, loaded0)
		flag = true
	#endregion
