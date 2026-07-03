extends Area2D

func _ready() -> void:
	$AnimatedSprite2D.play()
 
func _on_body_entered(_body: Node2D) -> void:
	SFXManager.play_sfx(SFXManager.DAMAGE, SFXManager.DAMAGE_VOLUME)
	GameManager.local_save["player"]["lives"] -= 1
	PycoLog.log_event_by_type("death", {"level": GameManager.local_save["level"]["scene_number"], "lives_left": GameManager.local_save["player"]["lives"]})
	# Сохранение НЕ вызываем здесь — это блокирующая запись на диск прямо во время игры.
	# Данные сохранятся автоматически через SaveManager._commit_cache() при паузе или выходе.
	Events.GAME_ON_LOSE.emit()
