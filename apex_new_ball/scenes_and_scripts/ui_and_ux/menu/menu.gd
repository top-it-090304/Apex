extends Node2D

var timer = 0
var flag1 = false
enum BUTTON_PLAY {Play1, Play2, Play3}
enum BUTTON_DELETE {Delete1, Delete2, Delete3}

const _REF_W := 1280.0
const _REF_H := 720.0

func _ready():
	print("=== MENU STARTED ===")
	$black_canvas.modulate = Color.BLACK
	get_viewport().size_changed.connect(_reflow_menu)
	call_deferred("_reflow_menu")

func _reflow_menu() -> void:
	var r := get_viewport().get_visible_rect()
	var w: float = r.size.x
	var h: float = r.size.y
	if w <= 0.0 or h <= 0.0:
		return
	var scale_ref: float = minf(w / _REF_W, h / _REF_H)
	var btn_w: float = clampf(317.0 * scale_ref, minf(260.0, w * 0.85), minf(420.0, w * 0.92))
	var btn_h: float = clampf(66.0 * scale_ref, 44.0, 96.0)
	var gap: float = clampf(15.0 * scale_ref, 8.0, 28.0)
	var total_h: float = btn_h * 4.0 + gap * 3.0
	var left_x: float = r.position.x + (w - btn_w) * 0.5
	var top_y: float = r.position.y + (h - total_h) * 0.5
	var font_size: int = int(clampf(30.0 * scale_ref, 18.0, 40.0))
	# Фон Parallax: нижний край слоёв (anchor_bottom_extent) совмещаем с низом видимой области.
	var parallax: Parallax2D = $Parallax
	var bottom_extent: float = parallax.get_anchor_bottom_extent()
	parallax.position = Vector2(r.position.x, r.position.y + r.size.y - bottom_extent)
	# Полноэкранная подложка для затемнения (если используется).
	var c: Vector2 = r.position + r.size * 0.5
	$black_canvas.position = c
	$black_canvas.scale = Vector2(r.size.x, r.size.y)
	var buttons: Array = [$Play1, $Play2, $Play3, $Quit]
	var deletes: Array = [$Delete1, $Delete2, $Delete3]
	
	for i in range(buttons.size()):
		var b: Button = buttons[i]
		b.position = Vector2(left_x, top_y + i * (btn_h + gap))
		b.size = Vector2(btn_w, btn_h)
		b.add_theme_font_size_override("font_size", font_size)
		
	for i in range(deletes.size()):
		var d: Button = deletes[i]
		d.position = Vector2(75 + left_x + btn_w - btn_h, top_y + i * (btn_h + gap))
		d.size = Vector2(btn_h, btn_h)

func _process(_delta):
	if flag1 != true:
		timer += 10
		if timer >= 40 && $black_canvas.modulate.a > 0:
			$black_canvas.modulate.a -= 0.02
			timer = 0

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_1_pressed() -> void:
	SaveManager.slot_save = 0
	Events.BUTTON_PLAY_PRESSED.emit(BUTTON_PLAY.Play1)

func _on_play_2_pressed() -> void:
	SaveManager.slot_save = 1
	Events.BUTTON_PLAY_PRESSED.emit(BUTTON_PLAY.Play2)

func _on_play_3_pressed() -> void:
	SaveManager.slot_save = 2
	Events.BUTTON_PLAY_PRESSED.emit(BUTTON_PLAY.Play3)


func _on_delete_1_pressed() -> void:
	SaveManager.slot_save = 0
	Events.BUTTON_DELETE_PRESSED.emit(BUTTON_DELETE.Delete1)

func _on_delete_2_pressed() -> void:
	SaveManager.slot_save = 1
	Events.BUTTON_DELETE_PRESSED.emit(BUTTON_DELETE.Delete2)

func _on_delete_3_pressed() -> void:
	SaveManager.slot_save = 2
	Events.BUTTON_DELETE_PRESSED.emit(BUTTON_DELETE.Delete3)
