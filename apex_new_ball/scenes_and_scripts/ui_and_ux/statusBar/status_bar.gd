extends Node

@onready var label1 = $HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/Label1
@onready var label2 = $HBoxContainer/PanelContainer2/MarginContainer/HBoxContainer/Label2
@onready var label3 = $HBoxContainer2/PanelContainer2/MarginContainer/HBoxContainer/Label3

@onready var modal = $modalWindow2
@onready var to_main_menu_btn = $modalWindow2/RowsButtons/ToMainMenu
@onready var reload_btn = $modalWindow2/RowsButtons/Reload
@onready var music_btn = $modalWindow2/RowsButtons/ToggleMusic
@onready var play_btn = $modalWindow2/RowsButtons/Continue

var _fps_label: Label
var _fps_timer: float = 0.0


func _ready() -> void:
	#region Добавляем в статус бар информацию взятую из конфига о жизнях, флагах, и очках
	label1.text = "x " + str(GameManager.local_save["player"]["lives"])
	label2.text = str(GameManager.local_save["level"]["flags_collected"]) + "/" + str(GameManager.local_save["level"]["flags_total"])
	label3.text = str(GameManager.local_save["player"]["score"])
	#endregion
	
	modal.visible = false
	to_main_menu_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	reload_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	music_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	play_btn.process_mode = Node.PROCESS_MODE_ALWAYS
	
	to_main_menu_btn.pressed.connect(_on_quit_menu_pressed)
	reload_btn.pressed.connect(_on_continue_2_pressed)
	play_btn.pressed.connect(_on_continue_pressed)
	music_btn.toggled.connect(_on_music_toggled)
	
	# Если громкость > 0 (музыка включена), показываем действие "Выключить" (music_off.png) -> кнопка НЕ нажата.
	# Если громкость <= 0 (музыка выключена), показываем действие "Включить" (music_on.png) -> кнопка НАЖАТА.
	music_btn.set_pressed_no_signal(GameManager.music_volume_percent <= 0)
	
	_apply_adaptive_layout()
	# Убрано постоянное прослушивание size_changed для экономии ресурсов
	
	Events.SHOW_PAUSE_MODAL.connect(_show_modal)
	Events.GAME_ON_LOSE.connect(_lose_modal)
	
	# Подключаем сигналы обновления UI
	Events.UI_SCORE_UPDATED.connect(_update_score)
	Events.UI_FLAGS_UPDATED.connect(_update_flags)
	Events.UI_LIVES_UPDATED.connect(_update_lives)

	# Создаем Label для FPS
	_fps_label = Label.new()
	_fps_label.name = "FPSLabel"
	_fps_label.add_theme_font_size_override("font_size", 24)
	_fps_label.modulate = Color(1, 1, 1, 0.7)
	add_child(_fps_label)
	_fps_label.position = Vector2(20, 80) # Позиция под статус-баром

	Events.HIDE_PAUSE_MODAL.connect(_hide_modal)
	
	# Первоначальное заполнение (flags_total может прийти чуть позже)
	call_deferred("_update_flags")

func _process(delta: float) -> void:
	if not GameManager.show_fps:
		if _fps_label and _fps_label.visible:
			_fps_label.visible = false
		return
		
	_fps_timer += delta
	if _fps_timer >= 0.5:
		_fps_timer = 0.0
		if _fps_label:
			if not _fps_label.visible:
				_fps_label.visible = true
			_fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func _update_score() -> void:
	label3.text = str(GameManager.local_save["player"]["score"])

func _update_flags() -> void:
	label2.text = str(GameManager.local_save["level"]["flags_collected"]) + "/" + str(GameManager.local_save["level"]["flags_total"])

func _update_lives() -> void:
	label1.text = "x " + str(GameManager.local_save["player"]["lives"])

func _on_pause_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	_show_modal()

func _on_continue_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	_hide_modal()

func _on_continue_2_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	_hide_modal()
	Events.PLAYER_RESPAWN.emit()

func _on_quit_menu_pressed() -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	_hide_modal()
		
	if GameManager.local_save["player"]["lives"] < 1:
		var final_score = GameManager.local_save["player"]["score"]
		PycoLog.log_event_by_type("game_over", {"level": GameManager.local_save["level"]["scene_number"], "score": final_score})
		SaveManager.delete()
		GameManager.local_save = SaveManager.get_default_data()
		Events.SHOW_LEADERBOARD_SUBMIT.emit(final_score)
	else:
		SaveManager.save(GameManager.local_save) #Сохраняю то что было сделано за ввремя игры в удаленный сейв.
		get_tree().change_scene_to_file("res://scenes_and_scripts/ui_and_ux/menu/main_menu.tscn")


func _sync_music_button() -> void:
	music_btn.set_pressed_no_signal(GameManager.music_volume_percent <= 0)

func _show_modal() -> void:
	get_tree().paused = true
	MusicManager.set_paused(true)
	reload_btn.visible = false
	play_btn.visible = true
	_sync_music_button()
	modal.visible = true

func _lose_modal() -> void:
	get_tree().paused = true
	MusicManager.set_paused(true)
	play_btn.visible = false
	# local_save уже актуален (spike.gd уже вычел жизнь), лишнее чтение с диска убрано
	_update_lives()
	if GameManager.local_save["player"]["lives"] < 1:
		reload_btn.visible = false
	else:
		reload_btn.visible = true
	_sync_music_button()
	modal.visible = true

func _hide_modal() -> void:
	get_tree().paused = false
	MusicManager.set_paused(false)
	modal.visible = false

func _on_music_toggled(toggled_on: bool) -> void:
	SFXManager.play_sfx(SFXManager.CLICK, SFXManager.CLICK_VOLUME)
	
	# Убиваем возможный fade_tween, чтобы он не перезаписал громкость
	if MusicManager.fade_tween:
		MusicManager.fade_tween.kill()
		MusicManager.fade_tween = null
	
	if toggled_on:
		# Кнопка перешла в нажатое состояние (показывает "Включить", music_on.png)
		# Значит, пользователь только что ВЫКЛЮЧИЛ музыку
		GameManager.set_music_volume_percent(0.0)
	else:
		# Кнопка перешла в ненажатое состояние (показывает "Выключить", music_off.png)
		# Значит, пользователь только что ВКЛЮЧИЛ музыку
		GameManager.set_music_volume_percent(75.0)

func _apply_adaptive_layout() -> void:
	if not has_node("HBoxContainer") or not has_node("HBoxContainer2") or not has_node("HBoxContainer3"):
		return
	
	var safe_rect = _get_safe_area_rect()
	var safe_pos = safe_rect.position
	var safe_size = safe_rect.size
	
	var min_side = min(safe_size.x, safe_size.y)
	var margin = clamp(min_side *0.025,14.0,42.0)
	
	# Левый блок (жизни + флаги)
	var left_panel = $HBoxContainer
	left_panel.offset_left = safe_pos.x + margin +72.0
	left_panel.offset_top = safe_pos.y + margin
	left_panel.offset_bottom = left_panel.offset_top +69.0
	
	# Правый блок (монеты)
	var right_panel = $HBoxContainer2
	var right_width = clamp(safe_size.x *0.24,220.0,320.0)
	right_panel.offset_right = safe_pos.x + safe_size.x - margin
	right_panel.offset_top = safe_pos.y + margin
	right_panel.offset_left = right_panel.offset_right - right_width
	right_panel.offset_bottom = right_panel.offset_top +69.0
	
	# Кнопка паузы слева сверху
	var pause_panel = $HBoxContainer3
	pause_panel.offset_left = safe_pos.x + margin
	pause_panel.offset_top = safe_pos.y + margin
	pause_panel.offset_right = pause_panel.offset_left +68.0
	pause_panel.offset_bottom = pause_panel.offset_top +69.0

func _get_safe_area_rect() -> Rect2:
	return get_viewport().get_visible_rect()
