extends Control

const _REF_W := 1280.0
const _REF_H := 720.0

@onready var _parallax: Parallax2D = $Parallax
@onready var _play_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/Play
@onready var _continue_restart_row: HBoxContainer = $MarginContainer/VBoxContainer/Buttons/ContinueRestartRow
@onready var _continue_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/ContinueRestartRow/Continue
@onready var _delete_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/ContinueRestartRow/Delete
@onready var _settings_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/Settings
@onready var _quit_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/Exit
@onready var _music_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/BottomButtons/TonggleMusic
@onready var _github_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/BottomButtons/GitHub
@onready var _about_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/BottomButtons/About

@onready var _about_window: CanvasLayer = $AboutWindow
@onready var _about_color_rect: ColorRect = $AboutWindow/ColorRect
@onready var _about_board: TextureRect = $AboutWindow/ModalCenter/BackgroundBoard
@onready var _close_about_button: TextureButton = $AboutWindow/ModalCenter/BackgroundBoard/CloseButton
@onready var _liderboard_button: TextureButton = $MarginContainer/VBoxContainer/Buttons/BottomButtons/LiderBoard

# LiderBoard Window
@onready var _liderboard_window: CanvasLayer = $LiderBoard
@onready var _liderboard_color_rect: ColorRect = $LiderBoard/ColorRect
@onready var _liderboard_board: TextureRect = $LiderBoard/ModalCenter/BackgroundBoard
@onready var _close_liderboard_button: TextureButton = $LiderBoard/ModalCenter/BackgroundBoard/CloseButton

# SettingWindow
@onready var _settings_window: CanvasLayer = $SettingWindow
@onready var _settings_color_rect: ColorRect = $SettingWindow/ColorRect
@onready var _settings_board: TextureRect = $SettingWindow/ModalCenter/BackgroundBoard
@onready var _close_settings_button: TextureButton = $SettingWindow/ModalCenter/BackgroundBoard/CloseButton
@onready var _music_slider: HSlider = $SettingWindow/ModalCenter/BackgroundBoard/MarginContainer/ScrollContainer/VBoxContainer/MusicRow/Controls/MusicSlider
@onready var _music_value_label: Label = $SettingWindow/ModalCenter/BackgroundBoard/MarginContainer/ScrollContainer/VBoxContainer/MusicRow/Controls/MusicValue
@onready var _sfx_slider: HSlider = $SettingWindow/ModalCenter/BackgroundBoard/MarginContainer/ScrollContainer/VBoxContainer/SfxRow/Controls/SfxSlider
@onready var _sfx_value_label: Label = $SettingWindow/ModalCenter/BackgroundBoard/MarginContainer/ScrollContainer/VBoxContainer/SfxRow/Controls/SfxValue
@onready var _sensitivity_slider: HSlider = $SettingWindow/ModalCenter/BackgroundBoard/MarginContainer/ScrollContainer/VBoxContainer/SensitivityRow/Controls/SensitivitySlider
@onready var _sensitivity_value_label: Label = $SettingWindow/ModalCenter/BackgroundBoard/MarginContainer/ScrollContainer/VBoxContainer/SensitivityRow/Controls/SensitivityValue
@onready var _vsync_button: CheckButton = $SettingWindow/ModalCenter/BackgroundBoard/MarginContainer/ScrollContainer/VBoxContainer/VsyncRow/Controls/VsyncButton
@onready var _show_fps_button: CheckButton = $SettingWindow/ModalCenter/BackgroundBoard/MarginContainer/ScrollContainer/VBoxContainer/ShowFpsRow/Controls/ShowFpsButton
@onready var _fps_slider: HSlider = $SettingWindow/ModalCenter/BackgroundBoard/MarginContainer/ScrollContainer/VBoxContainer/FpsRow/Controls/FpsSlider
@onready var _fps_value_label: Label = $SettingWindow/ModalCenter/BackgroundBoard/MarginContainer/ScrollContainer/VBoxContainer/FpsRow/Controls/FpsValue
@onready var _physics_slider: HSlider = $SettingWindow/ModalCenter/BackgroundBoard/MarginContainer/ScrollContainer/VBoxContainer/PhysicsRow/Controls/PhysicsSlider
@onready var _physics_value_label: Label = $SettingWindow/ModalCenter/BackgroundBoard/MarginContainer/ScrollContainer/VBoxContainer/PhysicsRow/Controls/PhysicsValue

func _ready() -> void:
	get_tree().paused = false
	MusicManager.play_track("res://assets/sound/pixeltown_heroes.ogg")

	if _parallax:
		_parallax.autoscroll_surfaces = true
		if _parallax.has_method("_update_autoscroll"):
			_parallax._update_autoscroll()

	# Подключаем сигналы кнопок
	_play_button.pressed.connect(_on_play_button_pressed)
	_continue_button.pressed.connect(_on_continue_button_pressed)
	_delete_button.pressed.connect(_on_delete_button_pressed)
	_settings_button.pressed.connect(_on_settings_button_pressed)
	_quit_button.pressed.connect(_on_quit_button_pressed)
	_music_button.toggled.connect(_on_music_toggled)
	_github_button.pressed.connect(_on_github_button_pressed)
	_about_button.pressed.connect(_on_about_button_pressed)
	
	_close_about_button.pressed.connect(_on_close_about_pressed)
	_liderboard_button.pressed.connect(_on_liderboard_button_pressed)
	_about_window.visible = false
	
	# LiderBoard Window
	_close_liderboard_button.pressed.connect(_on_close_liderboard_pressed)
	_liderboard_window.visible = false
	
	# SettingWindow: подключаем сигналы
	_close_settings_button.pressed.connect(_on_close_settings_pressed)
	_music_slider.value_changed.connect(_on_music_slider_value_changed)
	_sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	_sensitivity_slider.value_changed.connect(_on_sensitivity_slider_value_changed)
	_vsync_button.toggled.connect(_on_vsync_toggled)
	_show_fps_button.toggled.connect(_on_show_fps_toggled)
	_fps_slider.value_changed.connect(_on_fps_slider_value_changed)
	_physics_slider.value_changed.connect(_on_physics_slider_value_changed)
	_settings_window.visible = false
	
	# Инициализируем слайдеры текущими значениями из GameManager
	_music_slider.set_value_no_signal(GameManager.music_volume_percent)
	_sfx_slider.set_value_no_signal(GameManager.sfx_volume_percent)
	_sensitivity_slider.set_value_no_signal(GameManager.control_sensitivity)
	_music_value_label.text = str(int(round(GameManager.music_volume_percent)))
	_sfx_value_label.text = str(int(round(GameManager.sfx_volume_percent)))
	_sensitivity_value_label.text = String.num(GameManager.control_sensitivity, 1)
	
	_vsync_button.set_pressed_no_signal(GameManager.vsync_enabled)
	_update_vsync_button_text(GameManager.vsync_enabled)
	
	_show_fps_button.set_pressed_no_signal(GameManager.show_fps)
	_update_show_fps_button_text(GameManager.show_fps)
	
	_fps_slider.set_value_no_signal(GameManager.max_fps)
	_fps_value_label.text = str(GameManager.max_fps)
	
	_physics_slider.set_value_no_signal(GameManager.physics_ticks)
	_physics_value_label.text = str(GameManager.physics_ticks)
	
	_music_button.set_pressed_no_signal(GameManager.music_volume_percent <= 0)

	_refresh_buttons()

	get_viewport().size_changed.connect(_apply_adaptive_layout)
	call_deferred("_apply_adaptive_layout")

func _apply_adaptive_layout() -> void:
	var rect := get_viewport().get_visible_rect()
	if rect.size.x <= 0 or rect.size.y <= 0: return

	var scale_ref := minf(rect.size.x / _REF_W, rect.size.y / _REF_H)

	if _parallax:
		_parallax.position = Vector2(rect.position.x, rect.position.y + rect.size.y - _parallax.get_anchor_bottom_extent())

	var btn_h := clampf(80.0 * scale_ref, 60.0, 100.0)
	_play_button.custom_minimum_size.y = btn_h
	_continue_button.custom_minimum_size.y = btn_h
	_delete_button.custom_minimum_size.y = btn_h
	_settings_button.custom_minimum_size.y = btn_h
	_quit_button.custom_minimum_size.y = btn_h

#region Переключение видимости кнопок в зависимости от наличия сейва
func _refresh_buttons() -> void:
	var has_save := SaveManager.exists()
	_play_button.visible = not has_save
	_continue_restart_row.visible = has_save
#endregion

#region Кнопка запуска новой игры (когда сейва нет)
func _on_play_button_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	SaveManager.save(SaveManager.get_default_data())
	GameManager.local_save = SaveManager.load()
	PycoLog.log_event_by_type("game_new", {})
	get_tree().change_scene_to_file(GameManager.local_save["level"]["current_scene"])
#endregion

#region Кнопка продолжения игры (когда сейв есть)
func _on_continue_button_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	GameManager.local_save = SaveManager.load()
	var path: String = GameManager.local_save["level"]["current_scene"]
	if not ResourceLoader.exists(path):
		push_warning("Сейв ссылается на отсутствующую сцену: " + path)
		SaveManager.delete()
		GameManager.local_save = SaveManager.get_default_data()
		_refresh_buttons()
		return
	PycoLog.log_event_by_type("game_continue", {"scene_number": GameManager.local_save["level"]["scene_number"]})
	get_tree().change_scene_to_file(path)
#endregion

#region Кнопка удаления сохранения (Restart) — стирает сейв, UI возвращается к "новой игре"
func _on_delete_button_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	PycoLog.log_event_by_type("save_delete", {})
	SaveManager.delete()
	GameManager.local_save = SaveManager.get_default_data()
	_refresh_buttons()
#endregion

#region Кнопка открытия настроек
func _on_settings_button_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	_settings_color_rect.modulate.a = 0.0
	_settings_board.modulate.a = 0.0
	_settings_window.visible = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_settings_color_rect, "modulate:a", 1.0, 0.3)
	tween.tween_property(_settings_board, "modulate:a", 1.0, 0.3)
#endregion

#region Кнопка выхода из игры
func _on_quit_button_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	if SaveManager.exists():
		SaveManager.save(GameManager.local_save)
	await PycoLog.log_stop_playing()
	get_tree().quit()
#endregion

func _on_music_toggled(toggled_on: bool) -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	
	# Убиваем возможный fade_tween, чтобы он не перезаписал громкость
	if MusicManager.fade_tween:
		MusicManager.fade_tween.kill()
		MusicManager.fade_tween = null
	
	if toggled_on:
		GameManager.set_music_volume_percent(0.0)
	else:
		GameManager.set_music_volume_percent(75.0)

func _on_github_button_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	OS.shell_open("https://github.com/top-it-090304/Apex")

func _on_about_button_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	_about_color_rect.modulate.a = 0.0
	_about_board.modulate.a = 0.0
	_about_window.visible = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_about_color_rect, "modulate:a", 1.0, 0.3)
	tween.tween_property(_about_board, "modulate:a", 1.0, 0.3)

func _on_close_about_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_about_color_rect, "modulate:a", 0.0, 0.3)
	tween.tween_property(_about_board, "modulate:a", 0.0, 0.3)
	tween.set_parallel(false)
	tween.tween_callback(func(): _about_window.visible = false)

func _on_rich_text_label_meta_clicked(meta) -> void:
	OS.shell_open(str(meta))

func _on_liderboard_button_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	_refresh_liderboard()
	_liderboard_color_rect.modulate.a = 0.0
	_liderboard_board.modulate.a = 0.0
	_liderboard_window.visible = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_liderboard_color_rect, "modulate:a", 1.0, 0.3)
	tween.tween_property(_liderboard_board, "modulate:a", 1.0, 0.3)

func _refresh_liderboard() -> void:
	var rows_container = $LiderBoard/ModalCenter/BackgroundBoard/MarginContainer/ScrollContainer/Rows
	var line_template = rows_container.get_node("Line")
	
	# Очищаем старые строки, кроме шаблона
	for child in rows_container.get_children():
		if child != line_template:
			child.queue_free()
	
	var leaderboard_data = SaveManager.get_leaderboard()
	
	if leaderboard_data.is_empty():
		line_template.visible = true
		line_template.get_node("MarginContainer/HBoxContainer/Position/Label").text = "-"
		line_template.get_node("MarginContainer/HBoxContainer/Name/Label").text = "Нет рекордов"
		line_template.get_node("MarginContainer/HBoxContainer/Score/Label").text = "0"
		return

	line_template.visible = false # Скрываем шаблон
	
	for i in range(leaderboard_data.size()):
		var entry = leaderboard_data[i]
		var new_line = line_template.duplicate()
		new_line.visible = true
		rows_container.add_child(new_line)
		
		new_line.get_node("MarginContainer/HBoxContainer/Position/Label").text = str(i + 1)
		new_line.get_node("MarginContainer/HBoxContainer/Name/Label").text = entry["name"]
		new_line.get_node("MarginContainer/HBoxContainer/Score/Label").text = str(entry["score"])


func _on_close_liderboard_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_liderboard_color_rect, "modulate:a", 0.0, 0.3)
	tween.tween_property(_liderboard_board, "modulate:a", 0.0, 0.3)
	tween.set_parallel(false)
	tween.tween_callback(func(): _liderboard_window.visible = false)

# ===== SettingWindow =====

func _on_close_settings_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(_settings_color_rect, "modulate:a", 0.0, 0.3)
	tween.tween_property(_settings_board, "modulate:a", 0.0, 0.3)
	tween.set_parallel(false)
	tween.tween_callback(func(): _settings_window.visible = false)

func _on_music_slider_value_changed(value: float) -> void:
	GameManager.set_music_volume_percent(value)
	_music_value_label.text = str(int(round(value)))
	# Синхронизируем кнопку ToggleMusic
	_music_button.set_pressed_no_signal(value <= 0)

func _on_sfx_slider_value_changed(value: float) -> void:
	GameManager.set_sfx_volume_percent(value)
	_sfx_value_label.text = str(int(round(value)))

func _on_sensitivity_slider_value_changed(value: float) -> void:
	GameManager.set_control_sensitivity(value)
	_sensitivity_value_label.text = String.num(value, 1)

func _on_vsync_toggled(toggled_on: bool) -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	GameManager.set_vsync(toggled_on)
	_update_vsync_button_text(toggled_on)

func _update_vsync_button_text(enabled: bool) -> void:
	if enabled:
		_vsync_button.text = "Включено"
	else:
		_vsync_button.text = "Выключено"

func _on_show_fps_toggled(toggled_on: bool) -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	GameManager.set_show_fps(toggled_on)
	_update_show_fps_button_text(toggled_on)

func _update_show_fps_button_text(enabled: bool) -> void:
	if enabled:
		_show_fps_button.text = "Включено"
	else:
		_show_fps_button.text = "Выключено"

func _on_fps_slider_value_changed(value: float) -> void:
	var fps = int(value)
	GameManager.set_max_fps(fps)
	_fps_value_label.text = str(fps)

func _on_physics_slider_value_changed(value: float) -> void:
	var ticks = int(value)
	GameManager.set_physics_ticks(ticks)
	_physics_value_label.text = str(ticks)
