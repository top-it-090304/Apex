extends Parallax2D

var speed = 20 as int

func _ready() -> void:
	$Surface1.autoscroll = Vector2(-10, 0)
	$Surface2.autoscroll = Vector2(-12.5, 0)
	$Surface3.autoscroll = Vector2(-25, 0)
	$Surface4.autoscroll = Vector2(-45, 0)
	$Surface5.autoscroll = Vector2(-50, 0)
