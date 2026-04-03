extends Parallax2D

## Только для меню: автопрокрутка слоёв. На уровнях оставлять выключенным.
@export var autoscroll_surfaces: bool = false

## На очень широких соотношениях сторон внутренний repeat у Parallax2D иногда не дорисовывает правый край —
## добавляем физические копии спрайта по repeat_size.x (совпадает с шириной тайла 576*2).
@export var extra_repeat_tiles: int = 2

## Нижний край «земли»/деревьев в локальных координатах корня Parallax (нижняя граница слоёв Surface при scale=2).
## Нужен меню и другим сценам, чтобы привязать фон к низу вьюпорта: position.y = viewport_bottom - anchor_bottom_extent.
@export var anchor_bottom_extent: float = 648.0

func get_anchor_bottom_extent() -> float:
	return anchor_bottom_extent

func _ready() -> void:
	if autoscroll_surfaces:
		$Surface1.autoscroll = Vector2(-10, 0)
		$Surface2.autoscroll = Vector2(-12.5, 0)
		$Surface3.autoscroll = Vector2(-25, 0)
		$Surface4.autoscroll = Vector2(-45, 0)
		$Surface5.autoscroll = Vector2(-50, 0)
	else:
		$Surface1.autoscroll = Vector2.ZERO
		$Surface2.autoscroll = Vector2.ZERO
		$Surface3.autoscroll = Vector2.ZERO
		$Surface4.autoscroll = Vector2.ZERO
		$Surface5.autoscroll = Vector2.ZERO

	_add_extra_parallax_repeat_coverage()

func _add_extra_parallax_repeat_coverage() -> void:
	if extra_repeat_tiles <= 0:
		return
	for layer in get_children():
		if not layer is Parallax2D:
			continue
		var rs: Vector2 = layer.repeat_size
		if rs.x <= 0.0:
			continue
		var to_dup: Array[Sprite2D] = []
		for c in layer.get_children():
			if c is Sprite2D:
				to_dup.append(c as Sprite2D)
		for base in to_dup:
			for i in range(1, extra_repeat_tiles + 1):
				var copy := base.duplicate() as Sprite2D
				copy.position = base.position + Vector2(rs.x * float(i), 0.0)
				copy.name = "%s_wide_%d" % [base.name, i]
				layer.add_child(copy)
