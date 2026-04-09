extends Node

@onready var label1 = $HBoxContainer/PanelContainer/MarginContainer/HBoxContainer/Label1
@onready var label2 = $HBoxContainer/PanelContainer2/MarginContainer/HBoxContainer/Label2
@onready var label3 = $HBoxContainer2/PanelContainer2/MarginContainer/HBoxContainer/Label3

@onready var modal = $modalWindow2
@onready var continue1 = $modalWindow2/Continue
@onready var continue2 = $modalWindow2/Continue2

var flag = false

func _ready() -> void:
	#region Добавляем в статус бар информацию взятую из конфига о жизнях, флагах, и очках
	var _loaded = SaveManager.load_slot(SaveManager.slot_save)
	label1.text = "x " + str(_loaded["player"]["lives"])
	label2.text = str(_loaded["level"]["flags_collected"]) + "/" + str(_loaded["level"]["flags_total"])
	label3.text = str(_loaded["player"]["score"])
	#endregion
	
	modal.visible = false
	$modalWindow2/Continue.process_mode = Node.PROCESS_MODE_ALWAYS
	$modalWindow2/Continue2.process_mode = Node.PROCESS_MODE_ALWAYS
	$modalWindow2/QuitMenu.process_mode = Node.PROCESS_MODE_ALWAYS
	
	_apply_adaptive_layout()
	get_viewport().size_changed.connect(_apply_adaptive_layout)
	
	Events.SHOW_PAUSE_MODAL.connect(_show_modal)
	Events.GAME_ON_LOSE.connect(_lose_modal)
	Events.HIDE_PAUSE_MODAL.connect(_hide_modal)

func _process(_delta: float) -> void:
	#region Добавляем информацию о флагах в статус бар так как _ready() срабатывает быстрее прочтения .json 
	if flag == false:
		var _loaded = SaveManager.load_slot(SaveManager.slot_save)
		label2.text = str(_loaded["level"]["flags_collected"]) + "/" + str(_loaded["level"]["flags_total"])
		flag = true
	#endregion
	
	#region Обновляем очки счета каждый раз при срабатывании сигнала сбора
	if GameManager.coin > 0:
		var _loaded = SaveManager.load_slot(SaveManager.slot_save)
		label3.text = str(_loaded["player"]["score"])
		GameManager.coin -= 1
	#endregion
	
	#region
	if GameManager.flag > 0:
		var _loaded = SaveManager.load_slot(SaveManager.slot_save)
		label2.text = str(_loaded["level"]["flags_collected"]) + "/" + str(_loaded["level"]["flags_total"])
		GameManager.flag -= 1
	#endregion
	
	#region
	if GameManager.live > 0:
		var _loaded = SaveManager.load_slot(SaveManager.slot_save)
		label1.text = "x " + str(_loaded["player"]["lives"])
		GameManager.live -= 1
	#endregion

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
	
	var _loaded = SaveManager.load_slot(SaveManager.slot_save)
	if _loaded["player"]["lives"] < 1:
		SaveManager.delete_slot(SaveManager.slot_save)
		print("Сейв удален (0 жизней)")
	
	get_tree().change_scene_to_file("res://scenes_and_scripts/ui_and_ux/menu/menu.tscn")

func _show_modal() -> void:
	get_tree().paused = true
	MusicManager.set_paused(true)
	continue2.visible = false
	continue1.visible = true
	modal.visible = true

func _lose_modal() -> void:
	get_tree().paused = true
	MusicManager.set_paused(true)
	continue1.visible = false
	var _loaded = SaveManager.load_slot(SaveManager.slot_save)
	if _loaded["player"]["lives"] < 1:
		continue2.visible = false
	else:
		continue2.visible = true
	modal.visible = true

func _hide_modal() -> void:
	get_tree().paused = false
	MusicManager.set_paused(false)
	modal.visible = false

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
