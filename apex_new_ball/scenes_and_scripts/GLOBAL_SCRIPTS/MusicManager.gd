extends Node

var player1: AudioStreamPlayer
var player2: AudioStreamPlayer
var current_player: AudioStreamPlayer

var current_track_path: String = ""
var fade_duration: float = 1.5 # Длительность перехода в секундах
var fade_tween: Tween # Ссылка на текущую анимацию громкости

# Целевая громкость музыки по умолчанию (в децибелах).
var music_volume_db: float = -10.0

func _ready() -> void:
	# Менеджер работает всегда, даже на паузе
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Создаем два плеера
	player1 = AudioStreamPlayer.new()
	player2 = AudioStreamPlayer.new()

	add_child(player1)
	add_child(player2)

	player1.bus = "Master"
	player2.bus = "Master"

	current_player = player1

func set_paused(is_paused: bool):
	player1.stream_paused = is_paused
	player2.stream_paused = is_paused

# Метод для ручного изменения громкости (например, из настроек)
func set_volume(db: float):
	music_volume_db = db
	if current_player:
		current_player.volume_db = db

func play_track(path: String, volume: float = -10.0):
	if current_track_path == path:
		if fade_tween:
			fade_tween.kill()
		fade_tween = create_tween()
		fade_tween.tween_property(current_player, "volume_db", volume, 0.5)
		return

	var new_stream = load(path)
	if not new_stream:
		print("MusicManager: Ошибка загрузки -> ", path)
		return

	if new_stream is AudioStreamOggVorbis:
		new_stream.loop = true
	elif new_stream is AudioStreamWAV:
		new_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

	if fade_tween:
		fade_tween.kill()

	# Определяем плееры для кроссфейда
	var next_player = player2 if current_player == player1 else player1
	var prev_player = current_player

	next_player.stream = new_stream
	next_player.volume_db = -80 # Начинаем с тишины
	next_player.play()

	fade_tween = create_tween().set_parallel(true)

	fade_tween.tween_property(next_player, "volume_db", volume, fade_duration).set_trans(Tween.TRANS_SINE)

	# Плавно гасим СТАРЫЙ трек до тишины
	if prev_player.playing:
		fade_tween.tween_property(prev_player, "volume_db", -80.0, fade_duration).set_trans(Tween.TRANS_SINE)
		fade_tween.chain().tween_callback(prev_player.stop)

	current_player = next_player
	current_track_path = path

func stop_all(duration: float = 1.0):
	if fade_tween:
		fade_tween.kill()

	fade_tween = create_tween().set_parallel(true)
	fade_tween.tween_property(player1, "volume_db", -80.0, duration)
	fade_tween.tween_property(player2, "volume_db", -80.0, duration)
	fade_tween.chain().tween_callback(func():
		player1.stop()
		player2.stop()
		current_track_path = ""
	)
