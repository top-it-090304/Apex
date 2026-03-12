extends Area2D

func _ready() -> void:
	$AnimatedSprite2D.play()
 
func _on_body_entered(_body: Node2D) -> void:
	Events.GAME_ON_PAUSE.emit()
