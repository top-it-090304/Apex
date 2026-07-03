extends Node

# Сессия = от запуска игры до ЗАКРЫТИЯ. session_id НЕ пересоздаётся на сворачивание.
# session_duration = только foreground-время (фон в зачёт не идёт).
var _is_paused: bool = false  ## true = игра свёрнута/в фоне (таймер активного времени на паузе)
var _active_accum: float = 0.0  ## Накопленное активное (foreground) время сессии, сек
var _last_resume_unix: float = 0.0  ## unix-время последнего входа в foreground
var _session_start_unix: float = 0.0  ## Реальное время старта сессии (unix), для справки

var _event_queue: PackedStringArray
var _http_request: AwaitableHTTPRequest
var _shutdown_initiated: bool = false
var _last_flush: float
const _url_suffix: String = "v1.0/events"

var flush_period_msec: float = 2000.0  ## Send batched events to server at least this often.
var queue_limit: int = 10  ## Send a batch of events if the queue is at least this long. Helps avoid frame stutter from too many events.
var request_timeout: float = 30.0  ## Number of seconds after which the event logging requests timeout. Will result in lost events.
# PROD: боевой сервер Aleksandr'а (effective.games каталог).
var url: String = "http://37.252.20.174:8103/" + _url_suffix  ## The exact server url for accepting batch requests (eg. including "v1.0/events").
# Общая соль от Aleksandr'а — ОДИНАКОВАЯ для всех 9 игр.
var hash_salt: String = "2ab6f74e"
var startup_callable: Callable  ## Callable returning a PycoEvent to send after the zeroth frame. Set to null to disable.
var shutdown_callable: Callable  ## Callable returning a PycoEvent to send on NOTIFICATION_WM_CLOSE_REQUEST. Set to null to disable.

signal shutdown_event_sent  ## Emitted after the shutdown event defined by shutdown_callable was sent.


func _ready() -> void:
	# ALWAYS: продолжаем флашить очередь даже когда дерево на паузе (фон/пауз-меню).
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Боевой api-key от Aleksandr'а.
	PycoEvent.default_event.api_key = "3b8ced07-7f00-4738-bfea-96f04b1d098c"

	# Тестовая пометка событий (value.is_test). По умолчанию ВКЛ.
	# Снимается ТОЛЬКО в сборке с custom feature "production" (export-пресет Rustore).
	# Редактор/обычный экспорт/друзьям → is_test=true. Боевой пресет → false.
	PycoEvent.test_mode = not OS.has_feature("production")
	PycoEvent.default_event.application = ProjectSettings.get_setting_with_override(
		&"application/config/name"
	)
	PycoEvent.default_event.platform = OS.get_name()
	PycoEvent.default_event.version = ProjectSettings.get_setting_with_override(
		&"application/config/version"
	)
	PycoEvent.default_event.user_id = _generate_user_id()
	PycoEvent.default_event.session_id = (
		(PycoEvent.default_event.user_id + str(Time.get_unix_time_from_system())).sha256_text()
	)

	_event_queue = PackedStringArray()

	startup_callable = _get_startup_event
	shutdown_callable = _get_shutdown_event

	_http_request = _create_request()

	_session_start_unix = Time.get_unix_time_from_system()
	_last_resume_unix = _session_start_unix
	_active_accum = 0.0
	# Явный старт сессии — ОДИН раз за lifetime. session_id задан выше и НЕ меняется.
	log_event_by_type.call_deferred("start_playing", {})


func _process(_delta: float) -> void:
	if Time.get_ticks_msec() - _last_flush > flush_period_msec:
		_flush_queue()


func _notification(what: int) -> void:
	match what:
		# Обработка закрытия игры
		NOTIFICATION_WM_CLOSE_REQUEST:
			_handle_game_close()
		
		# Сворачивание (мобильный фон) → сессия завершается + игра на паузу
		NOTIFICATION_APPLICATION_PAUSED:
			_handle_background("mobile_background")
		NOTIFICATION_APPLICATION_RESUMED:
			_handle_foreground("mobile_foreground")

		# Потеря/получение фокуса (desktop + сворачивание на части платформ) → то же
		NOTIFICATION_WM_WINDOW_FOCUS_OUT, NOTIFICATION_APPLICATION_FOCUS_OUT:
			_handle_background("focus_lost")
		NOTIFICATION_WM_WINDOW_FOCUS_IN, NOTIFICATION_APPLICATION_FOCUS_IN:
			_handle_foreground("focus_gained")
		
		# Обработка кнопки "Назад" на Android
		NOTIFICATION_WM_GO_BACK_REQUEST:
			_handle_back_button()	


func _log_startup() -> void:
	if startup_callable != null:
		log_event(startup_callable.call())
		log_event_by_type("test", {
			"doc": OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS),
			"down": OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS),
			"data": OS.get_data_dir(),
			"user_dir": OS.get_user_data_dir(),
		})


func _create_request() -> AwaitableHTTPRequest:
	var http_request := AwaitableHTTPRequest.new()
	add_child(http_request)
	#http_request.use_threads = true
	http_request.timeout = request_timeout
	return http_request


func _get_startup_event() -> PycoEvent:
	var event := PycoEvent.copy_default()
	event.event_type = "startup"
	return event


func _get_shutdown_event() -> PycoEvent:
	var event := PycoEvent.copy_default()
	event.event_type = "shutdown"
	return event


#func _generate_user_id() -> String:
	## OS.get_unique_id() returns a unique _hardware_ identifier on some
	## platforms, so we try to scramble it a bit with some user-unique details.
	## This should make it harder to match to hardware id-s from other sources.
	##
	## If you are reading this and you know a better way to do this,
	## please hit me up on the github.
	 ##ProjectSettings.get_setting_with_override(_Plugin.HASH_SALT_SETTING)
	#var unique_hash: String = str(OS.get_unique_id()).sha256_text().left(8)
	#var dir_hash: String = OS.get_data_dir().sha256_text().left(4)
	#var user_id: String = (unique_hash + dir_hash + hash_salt).sha256_text().left(8)
	#return user_id

func _generate_user_id() -> String:
	var file_path = "user://../common/userdata.json"
	
	# Пытаемся прочитать существующий файл
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file != null:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK and json.data is Dictionary:
				var data = json.data as Dictionary
				if data.has("user_id") and data["user_id"] is String and data["user_id"] != "":
					return data["user_id"]
		else:
			push_error("PycoLog: Failed to open userdata.json for reading")
	
	# Генерируем новый UUID если файл не найден или user_id отсутствует
	var new_user_id = _generate_uuid()

	# Каталог common общий для всех игр effective.games (user://../common).
	# Godot не создаёт родительские папки сам — создаём, иначе запись user_id
	# падает (Failed to save user_id) и UUID пересоздаётся каждый запуск.
	var common_dir := ProjectSettings.globalize_path("user://../common")
	if not DirAccess.dir_exists_absolute(common_dir):
		DirAccess.make_dir_recursive_absolute(common_dir)

	# Сохраняем в файл
	var save_file = FileAccess.open(file_path, FileAccess.WRITE)
	if save_file != null:
		var data = {"user_id": new_user_id}
		save_file.store_string(JSON.stringify(data))
		save_file.close()
		print("PycoLog: Generated new user_id: ", new_user_id)
	else:
		push_error("PycoLog: Failed to save user_id to userdata.json")
	
	return new_user_id


func _generate_uuid() -> String:
	# Генерируем UUID-подобную строку используя время, случайные числа и соль
	var time_msec = Time.get_unix_time_from_system()
	var random1 = randi()
	var random2 = randi()
	var random3 = randi()
	
	# Создаем строку из компонентов и хешируем
	var uuid_source = str(time_msec) + str(random1) + str(random2) + str(random3) + hash_salt
	var uuid_hash = uuid_source.sha256_text()
	
	# Форматируем как UUID (8-4-4-4-12)
	var formatted_uuid = "%s-%s-%s-%s-%s" % [
		uuid_hash.substr(0, 8),
		uuid_hash.substr(8, 4),
		uuid_hash.substr(12, 4),
		uuid_hash.substr(16, 4),
		uuid_hash.substr(20, 12)
	]
	
	return formatted_uuid

## Logs an event, overriding event_type and values with the provided parameters
func log_event_by_type(event_type: String, value: Dictionary = {}) -> void:
	var event: PycoEvent = PycoEvent.copy_default()
	event.event_type = event_type
	event.value = value
	log_event(event)


## Logs an event, overriding the specified values of the default event.
func log_event(pyco_event: PycoEvent) -> void:
	log_event_raw(PycoEvent.copy_default().merge(pyco_event))


## Logs an event as it is. Use PycoEvent.copy_default().merge(...) to selectively override event properties.
func log_event_raw(pyco_event: PycoEvent) -> void:
	if !_shutdown_initiated:
		_event_queue.append(pyco_event.to_json())
		if _event_queue.size() >= queue_limit:
			_flush_queue.call_deferred()
	else:
		push_warning(
			"PycoLog: Events logged after NOTIFICATION_WM_CLOSE_REQUEST are ignored: ",
			pyco_event.to_json()
		)


func _flush_queue() -> void:
	if _event_queue.size() == 0 || _http_request.is_requesting:
		return

	_last_flush = Time.get_ticks_msec()
	var events_to_send = _event_queue.duplicate() 
	var body: String = "[" + ",".join(events_to_send) + "]"
	_event_queue.clear()
	_event_queue = PackedStringArray()
	#[
			#"Content-Type: application/json",
			#"Accept: application/json"
		#]
	var result := await _http_request.async_request(
		url, 
		PackedStringArray(),
	 	HTTPClient.Method.METHOD_POST, 
		body
	)

	if result._error:
		print(
			"PycoLog: Error while creating HTTP connection to ", url,
			". Error code ", result._error, ": ", error_string(result._error)
		)
	elif result._result:
		print(
			"\nPycoLog: error while making a HTTP request to ", url,
			"\n    Result code ", result._result, ": ", result.result_message,
			"\n    HTTP status code: ", result.status_code,
			"\n    Respose Headers: ", result.headers,
			"\n    Response Body: ", result.body,
		)
	elif result.status_code > 400:
		print(
			"\nPycoLog: Error reply from server ", url,
			"\n    HTTP status code: ", result.status_code,
			"\n    Respose Headers: ", result.headers,
			"\n    Response Body: ", result.body,
		)


# Сворачивание/фон: таймер активного времени на ПАУЗУ + чекпойнт stop_playing
# с НАКОПЛЕННОЙ активной длительностью (тот же session_id). Сессия НЕ завершается —
# это контрольная точка на случай OS-kill из фона (Аврора не шлёт close).
# Заморозку игры (paused/max_fps/аудио) делает autoload AppFocus — здесь только аналитика.
func _handle_background(reason: String) -> void:
	if _is_paused or _shutdown_initiated:
		return
	_is_paused = true

	_active_accum += Time.get_unix_time_from_system() - _last_resume_unix
	log_event_by_type("stop_playing", {"session_duration": _active_accum, "reason": reason})

	print("PycoLog: session paused (backgrounded) - ", reason, " active=", _active_accum)

# Разворачивание: ПРОДОЛЖАЕМ ту же сессию (session_id НЕ меняется).
# Снимаем таймер активного времени с паузы. Событие не шлём.
# Распаузу/звук восстанавливает autoload AppFocus.
func _handle_foreground(reason: String) -> void:
	if not _is_paused:
		return
	_is_paused = false

	_last_resume_unix = Time.get_unix_time_from_system()

	print("PycoLog: session resumed (foreground) - ", reason)

func _handle_game_close() -> void:
	print("PycoLog: Game closing...")

	# Финальный конец сессии: stop_playing с итоговой активной длительностью.
	# Если уже свёрнуты — чекпойнт stop_playing уже ушёл с тем же значением, не дублируем.
	if not _is_paused:
		_active_accum += Time.get_unix_time_from_system() - _last_resume_unix
		log_event_by_type("stop_playing", {"session_duration": _active_accum, "reason": "close"})
		_is_paused = true

	# Ждем завершения текущего запроса
	if _http_request.is_requesting:
		await _http_request.request_finished

	# Отправляем shutdown событие (существующая логика)
	if shutdown_callable != null:
		log_event(shutdown_callable.call())

	_shutdown_initiated = true
	_flush_queue()
	await _http_request.request_finished
	shutdown_event_sent.emit()

func _handle_back_button() -> void:
	# На Android кнопка "Назад" может означать закрытие игры
	# Можно добавить логику подтверждения или сразу закрыть
	_handle_game_close()

func _get_pause_event(reason: String) -> PycoEvent:
	var event := PycoEvent.copy_default()
	event.event_type = "pause"
	event.value = {
		"reason": reason,
		"platform_specific": _get_platform_specific_data(),
		"timestamp": Time.get_unix_time_from_system()
	}
	return event

func _get_resume_event(reason: String, pause_duration: float) -> PycoEvent:
	var event := PycoEvent.copy_default()
	event.event_type = "resume"
	event.value = {
		"reason": reason,
		"pause_duration_seconds": pause_duration,
		"platform_specific": _get_platform_specific_data(),
		"timestamp": Time.get_unix_time_from_system()
	}
	return event

func _get_close_event() -> PycoEvent:
	var event := PycoEvent.copy_default()
	event.event_type = "close"
	event.value = {
		"platform_specific": _get_platform_specific_data(),
		"session_duration": Time.get_unix_time_from_system() - _get_session_start_time(),
		"timestamp": Time.get_unix_time_from_system()
	}
	return event

func _get_platform_specific_data() -> Dictionary:
	var data := {}
	
	match OS.get_name():
		"Linux":
			data["window_mode"] = DisplayServer.window_get_mode()
			data["window_focused"] = get_window().has_focus() if get_window() else false
		"Android", "iOS":
			data["mobile_platform"] = true
		_:
			data["desktop_platform"] = true
	
	return data

func _get_session_start_time() -> float:
	return _session_start_unix


## Явный конец игровой сессии (кнопка Выход в игре). Шлёт stop_playing с итоговой
## активной длительностью и ждёт отправки. Вызывать перед get_tree().quit().
func log_stop_playing() -> void:
	if not _is_paused:
		_active_accum += Time.get_unix_time_from_system() - _last_resume_unix
		_is_paused = true
	log_event_by_type("stop_playing", {"session_duration": _active_accum, "reason": "exit_button"})
	await _flush_queue()
