extends ParallaxBackground

var speed = 30 as int

func _process(delta: float) -> void:
	scroll_offset.x -= speed * delta
