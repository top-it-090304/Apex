extends Area2D

func _ready() -> void:
	$AnimatedSprite2D.play()
 
func _on_body_entered(_body: Node2D) -> void:
	Events.GAME_ON_LOSE.emit()
	GameManager.live += 1
	var loaded = SaveManager.load_slot(SaveManager.slot_save)
	loaded["player"]["lives"] -= 1
	SaveManager.save_slot(SaveManager.slot_save, loaded)
	if loaded["player"]["lives"] < 0:
		print("проиграл")
