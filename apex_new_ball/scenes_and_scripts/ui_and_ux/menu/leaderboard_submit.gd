extends CanvasLayer

@onready var name_input = $ModalCenter/BackgroundBoard/MarginContainer/VBoxContainer/LineEdit
@onready var save_button = $ModalCenter/BackgroundBoard/MarginContainer/VBoxContainer/SaveButton
@onready var skip_button = $ModalCenter/BackgroundBoard/MarginContainer/VBoxContainer/SkipButton
@onready var score_label = $ModalCenter/BackgroundBoard/MarginContainer/VBoxContainer/ScoreLabel

var current_score: int = 0

func _ready() -> void:
	visible = false
	save_button.pressed.connect(_on_save_pressed)
	skip_button.pressed.connect(_on_skip_pressed)
	Events.SHOW_LEADERBOARD_SUBMIT.connect(_show_modal)

func _show_modal(score: int) -> void:
	current_score = score
	score_label.text = "Ваш результат: " + str(score)
	visible = true
	get_tree().paused = true
	# Фокусируемся на вводе имени
	name_input.grab_focus()

func _on_save_pressed() -> void:
	var player_name = name_input.text.strip_edges()
	if player_name == "":
		player_name = "Player"
	
	SaveManager.save_score(player_name, current_score)
	PycoLog.log_event_by_type("leaderboard_submit", {"score": current_score})
	_close_and_continue()

func _on_skip_pressed() -> void:
	_close_and_continue()

func _close_and_continue() -> void:
	visible = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes_and_scripts/ui_and_ux/menu/main_menu.tscn")
