extends Node

# Используем два плеера для плавного перехода (Crossfade)
var player1: AudioStreamPlayer
var player2: AudioStreamPlayer
var current_player: AudioStreamPlayer

var current_track_path: String = ""
var fade_duration: float = 1.5 # Длительность затухания в секундах

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Создаем два плеера
	player1 = AudioStreamPlayer.new()
	player2 = AudioStreamPlayer.new()

	add_child(player1)
	add_child(player2)

	player1.bus = "Master"
	player2.bus = "Master"

	current_player = player1

func play_track(path: String):
	# Если трек уже играет — ничего не делаем
	if current_track_path == path:
		return

	var new_stream = load(path)
	if not new_stream:
		print("MusicManager: Ошибка загрузки -> ", path)
		return

	# Настройка зацикливания
	if new_stream is AudioStreamOggVorbis:
		new_stream.loop = true
	elif new_stream is AudioStreamWAV:
		new_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD

	# Определяем, какой плеер будет следующим, а какой затухающим
	var next_player = player2 if current_player == player1 else player1
	var prev_player = current_player

	# Настраиваем новый трек
	next_player.stream = new_stream
	next_player.volume_db = -80 # Начинаем с тишины
	next_player.play()

	# Плавная анимация громкости (Tween)
	var tween = create_tween().set_parallel(true)

	# Новый трек становится громче
	tween.tween_property(next_player, "volume_db", 0.0, fade_duration).set_trans(Tween.TRANS_SINE)

	# Старый трек затихает
	if prev_player.playing:
		tween.tween_property(prev_player, "volume_db", -80.0, fade_duration).set_trans(Tween.TRANS_SINE)
		# Останавливаем старый плеер только после завершения затухания
		tween.chain().tween_callback(prev_player.stop)

	current_player = next_player
	current_track_path = path
	print("MusicManager: Переход на трек -> ", path)

func stop_all(duration: float = 1.0):
	var tween = create_tween().set_parallel(true)
	tween.tween_property(player1, "volume_db", -80.0, duration)
	tween.tween_property(player2, "volume_db", -80.0, duration)
	tween.chain().tween_callback(func():
		player1.stop()
		player2.stop()
		current_track_path = ""
	)
