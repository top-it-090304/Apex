extends Node

var coin = 0
var flag = 0
var live = 0
var resp = 0
var pause_scene
var music_volume_percent: float = 75.0
var sfx_volume_percent: float = 100.0
var control_sensitivity: float = 5.0

func _ready() -> void:
	_load_user_settings()
	_apply_user_settings()

	Events.TOUCHING_THE_FLAG.connect(_touch)
	Events.COLLECTING_COINS.connect(_collect)
	Events.OPEN_THE_CHEST.connect(_chest)
	Events.OPEN_THE_DOOR.connect(_door)
	Events.BUTTON_PLAY_PRESSED.connect(_button)
	Events.BUTTON_DELETE_PRESSED.connect(_delete)
	Events.PLAYER_RESPAWN.connect(_respa)
	
	for i in range(3):
		var loaded = SaveManager.load_slot(i)
		if loaded["player"]["lives"] < 1:
			SaveManager.delete_slot(i)
			print("Сейв слота ", i, " удален (0 жизней)")
			if SaveManager.slot_exists(i):
				print("существует ", i)
			else: 
				print("не существует ", i)
				var data = SaveManager.get_default_data()
				data["player"]["id"] = i+1
				data["player"]["name"] = "Player" + str(i)
				data["player"]["score"] = 0
				SaveManager.save_slot(i, data)

func set_music_volume_percent(value: float) -> void:
	music_volume_percent = clampf(value, 0.0, 100.0)
	MusicManager.set_volume_percent(music_volume_percent)
	_save_user_settings()

func set_sfx_volume_percent(value: float) -> void:
	sfx_volume_percent = clampf(value, 0.0, 100.0)
	SFXManager.set_volume_percent(sfx_volume_percent)
	_save_user_settings()

func set_control_sensitivity(value: float) -> void:
	control_sensitivity = clampf(value, 1.0, 10.0)
	Events.CONTROL_SENSITIVITY_CHANGED.emit(control_sensitivity)
	_save_user_settings()

func _load_user_settings() -> void:
	var settings := SaveManager.load_settings()
	music_volume_percent = float(settings.get("music_volume", music_volume_percent))
	sfx_volume_percent = float(settings.get("sfx_volume", sfx_volume_percent))
	control_sensitivity = float(settings.get("control_sensitivity", control_sensitivity))

func _apply_user_settings() -> void:
	MusicManager.set_volume_percent(music_volume_percent)
	SFXManager.set_volume_percent(sfx_volume_percent)

func _save_user_settings() -> void:
	SaveManager.save_settings({
		"music_volume": music_volume_percent,
		"sfx_volume": sfx_volume_percent,
		"control_sensitivity": control_sensitivity
	})

func _touch(sprite):
	sprite.animation = "flag"
	flag += 1
	print("flag")

func _respa():
	resp += 1
	print(resp)

func _collect(sprite):
	sprite.modulate.a = 0
	coin += 1
	print("coin")

func _chest(sprite):
	sprite.animation = "chest"
	coin += 1
	print("chest")

func _door(sprite):
	sprite.animation = "open"
	print("door")

func _button(number_button):
	var loading = SaveManager.load_slot(number_button)
	print("запуск игры")
	get_tree().change_scene_to_file(loading["level"]["current_scene"])
		
func _delete(number_button):
	var data = SaveManager.get_default_data()
	print("удаление игры")
	SaveManager.save_slot(number_button, data)
