extends Node

func _ready() -> void:
	Events.GAME_ON_PAUSE.connect(_pause)
	Events.TOUCHING_THE_FLAG.connect(_touch)

func _pause():
	get_tree().paused = true
	if get_tree().paused:
		print(52)

func _touch(sprite):
	sprite.animation = "flag"
	print(123)
