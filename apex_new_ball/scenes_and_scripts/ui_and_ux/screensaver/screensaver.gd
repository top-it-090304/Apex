extends Node2D

const _REF_W := 1280.0
const _REF_H := 720.0

var _tap_shape: RectangleShape2D

func _ready() -> void:
	MusicManager.play_track("res://assets/sound/pixeltown_heroes.ogg")

	_ensure_tap_shape()
	_apply_layout()
	get_viewport().size_changed.connect(_apply_layout)

	$black_canvas.modulate = Color.BLACK
	$button/Label1.text = "tap to play"
	$button/Label1.modulate.a = 0
	$button/Label2.modulate.a = 0

	var font_px: int = int(clampf(72.0 * _layout_scale(), 28.0, 96.0))
	$button/Label1.add_theme_font_size_override("font_size", font_px)
	$button/Label2.add_theme_font_size_override("font_size", font_px)

	var tween = create_tween()
	tween.tween_property($black_canvas, "modulate:a", 0.0, 1.5)
	tween.tween_callback(_show_button)

func _ensure_tap_shape() -> void:
	if _tap_shape == null:
		_tap_shape = RectangleShape2D.new()
		$button.shape = _tap_shape

func _layout_scale() -> float:
	var r := get_viewport().get_visible_rect()
	if r.size.x <= 0.0 or r.size.y <= 0.0:
		return 1.0
	return minf(r.size.x / _REF_W, r.size.y / _REF_H)

func _apply_layout() -> void:
	var r := get_viewport().get_visible_rect()
	if r.size.x <= 0.0 or r.size.y <= 0.0:
		return
	var center: Vector2 = r.position + r.size * 0.5

	# Заливка на весь видимый прямоугольник (1×1 CanvasTexture масштабируем).
	$black_canvas.position = center
	$black_canvas.scale = Vector2(r.size.x, r.size.y)

	# Фоновая картинка: режим «cover», чтобы не было полос по бокам.
	var tex_size: Vector2 = $screen.texture.get_size()
	if tex_size.x > 0.0 and tex_size.y > 0.0:
		var sc: float = maxf(r.size.x / tex_size.x, r.size.y / tex_size.y)
		$screen.scale = Vector2(sc, sc)
		$screen.position = center

	# Весь экран — область нажатия.
	$button.position = r.position
	if _tap_shape:
		_tap_shape.size = r.size

	# Подпись по центру по горизонтали, чуть выше середины по вертикали.
	var label_h: float = clampf(112.0 * _layout_scale(), 72.0, 160.0)
	var top_y: float = r.size.y * 0.34
	for lbl in [$button/Label1, $button/Label2]:
		lbl.offset_left = 0
		lbl.offset_right = r.size.x
		lbl.offset_top = top_y
		lbl.offset_bottom = top_y + label_h

func _show_button() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property($button/Label1, "modulate:a", 1.0, 0.5)
	tween.tween_property($button/Label2, "modulate:a", 0.7, 0.5)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.pressed:
			_on_screen_pressed()

func _on_screen_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)

	var tween = create_tween().set_parallel(true)
	tween.tween_property($black_canvas, "modulate:a", 1.0, 0.8)
	tween.tween_property($button/Label1, "modulate:a", 0.0, 0.4)
	tween.tween_property($button/Label2, "modulate:a", 0.0, 0.4)

	tween.set_parallel(false)
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://scenes_and_scripts/ui_and_ux/menu/menu.tscn"))
