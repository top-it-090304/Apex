extends Node

# Универсальная функция для проигрывания звуковых эффектов.
# Вызывается вручную: SFXManager.play_sfx("res://path/to/sound.wav")
#
# path: путь к аудиофайлу
# volume: громкость в децибелах (0.0 - норма)

# Каталог звуков
const CLICK = "res://assets/sound/click.wav"
const COIN = "res://assets/sound/coin.wav"
const BOUNCE = "res://assets/sound/bounce.wav"
const DAMAGE = "res://assets/sound/damage.wav"

func play_sfx(path: String, volume: float = 0.0):
	# Проверка на существование файла
	if not FileAccess.file_exists(path):
		print("SFXManager: Файл не найден -> ", path)
		return

	var stream = load(path)
	if not stream:
		return

	# Создаем временный плеер
	var sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)

	sfx_player.stream = stream
	sfx_player.volume_db = volume
	sfx_player.bus = "Master"

	# Звуки эффектов должны работать и на паузе
	sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS

	sfx_player.play()

	# Удаляем плеер из памяти после завершения звука
	sfx_player.finished.connect(sfx_player.queue_free)
