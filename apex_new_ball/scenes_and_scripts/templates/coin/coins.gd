extends Area2D

var flag = false

func _ready() -> void:
	$AnimatedSprite2D.play()
	
func _on_body_entered(_body: Node2D) -> void:
	if flag == false:
		Events.COLLECTING_COINS.emit($AnimatedSprite2D)
		var loaded0 = SaveManager.load_slot(SaveManager.slot_save)
		loaded0["player"]["score"] = loaded0["player"]["score"] + 100
		SaveManager.save_slot(SaveManager.slot_save, loaded0)
		flag = true
