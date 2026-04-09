extends Node

# Универсальная функция для проигрывания звуковых эффектов.
# Вызывается вручную: SFXManager.play_sfx("res://path/to/sound.wav")
# path: путь к аудиофайлу
# volume: громкость в децибелах (0.0 - норма)

# Каталог звуков
const CLICK = "res://assets/sound/click.wav"
const COIN = "res://assets/sound/coin.wav"
const BOUNCE = "res://assets/sound/bounce.wav"
const DAMAGE = "res://assets/sound/damage.wav"
const JUMP = "res://assets/sound/jump.wav"
const DOOR = "res://assets/sound/door.ogg"

const CLICK_VOLUME = 5.0
const JUPM_VOLUME = -20.0
const COIN_VOLUME = -10.0
const DAMAGE_VOLUME = 2.0
const DOOR_VOLUME = 0.0

const MIN_VOLUME_DB := -40.0
const MUTED_VOLUME_DB := -80.0

var sfx_volume_db: float = 0.0

func set_volume_percent(percent: float) -> void:
	sfx_volume_db = _percent_to_db(percent)

func get_volume_percent() -> float:
	return _db_to_percent(sfx_volume_db)

func play_sfx(path: String, volume: float = 0.0):
	if not FileAccess.file_exists(path):
		print("SFXManager: Файл не найден -> ", path)
		return

	var stream = load(path)
	if not stream:
		return

	var sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)

	sfx_player.stream = stream
	sfx_player.volume_db = volume + sfx_volume_db
	sfx_player.bus = "Master"

	sfx_player.process_mode = Node.PROCESS_MODE_ALWAYS

	sfx_player.play()

	sfx_player.finished.connect(sfx_player.queue_free)

func _percent_to_db(percent: float) -> float:
	var clamped_percent := clampf(percent, 0.0, 100.0)
	if clamped_percent <= 0.0:
		return MUTED_VOLUME_DB
	return lerpf(MIN_VOLUME_DB, 0.0, clamped_percent / 100.0)

func _db_to_percent(db: float) -> float:
	if db <= MUTED_VOLUME_DB:
		return 0.0
	return clampf(inverse_lerp(MIN_VOLUME_DB, 0.0, db) * 100.0, 0.0, 100.0)
