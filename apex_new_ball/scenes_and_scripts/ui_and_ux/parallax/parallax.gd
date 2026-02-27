extends Parallax2D

var speed = 20 as int

func _process(delta: float) -> void:
	scroll_offset.x -= speed * delta
