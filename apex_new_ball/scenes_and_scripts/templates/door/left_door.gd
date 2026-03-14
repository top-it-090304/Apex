extends Area2D

var flag = false

func _ready() -> void:
	$AnimatedSprite2D.play()

func _on_body_entered(_body: Node2D) -> void:
	if flag == false:
		Events.OPEN_THE_DOOR.emit($AnimatedSprite2D)
		flag = true
