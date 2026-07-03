extends Node
## Автопауза игры при потере фокуса окна. Регистрируется как autoload AppFocus.

# FPS в фоне. НЕ 0 (0 в Godot = безлимит). 1 = минимальная нагрузка в фоне.
const BACKGROUND_FPS: int = 1

var _was_paused: bool = false        # была ли игра на паузе ДО потери фокуса
var _saved_max_fps: int = 0          # кап FPS до потери фокуса
var _paused_audio: Array[Node] = []  # плееры, которые мы сами поставили на паузу

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			_on_focus_out()
		NOTIFICATION_APPLICATION_FOCUS_IN:
			_on_focus_in()

func _on_focus_out() -> void:
	_was_paused = get_tree().paused
	_saved_max_fps = Engine.max_fps
	Engine.max_fps = BACKGROUND_FPS
	_pause_audio()
	get_tree().paused = true

func _on_focus_in() -> void:
	Engine.max_fps = _saved_max_fps
	_resume_audio()
	# Снимаем паузу только если игрок не ставил её сам (открытое меню паузы).
	if not _was_paused:
		get_tree().paused = false

func _pause_audio() -> void:
	_paused_audio.clear()
	_collect_and_pause(get_tree().root)

func _collect_and_pause(node: Node) -> void:
	if node is AudioStreamPlayer or node is AudioStreamPlayer2D or node is AudioStreamPlayer3D:
		if node.playing and not node.stream_paused:
			node.stream_paused = true
			_paused_audio.append(node)
	for child in node.get_children():
		_collect_and_pause(child)

func _resume_audio() -> void:
	for node in _paused_audio:
		if is_instance_valid(node):
			node.stream_paused = false
	_paused_audio.clear()
